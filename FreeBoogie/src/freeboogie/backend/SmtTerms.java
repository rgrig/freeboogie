package freeboogie.backend;

import java.util.*;

import com.google.common.collect.ImmutableList;
import genericutils.Id;
import genericutils.Pair;

/**
 * Utilities for handling {@code SmtTerm}s.
 */
public final class SmtTerms {
  private SmtTerms() { /* forbid instantiation */ }

  // === Functions for eliminating sharing ===
  
  /** Passed around by functions that eliminate sharing. */
  private static class EliminateSharingContext {
    public HashMap<SmtTerm, Integer> parentCount =
      new HashMap<SmtTerm, Integer>(31);
    public HashMap<SmtTerm, Integer> sizes =
      new HashMap<SmtTerm, Integer>(31);
    public HashMap<String, SmtTerm> varDefs =
      new HashMap<String, SmtTerm>(31);
    public HashMap<SmtTerm, SmtTerm> oldToNew =
      new HashMap<SmtTerm, SmtTerm>(31);
    public HashMap<SmtTerm, SmtTerm> unshared =
      new HashMap<SmtTerm, SmtTerm>(31);
    public HashMap<SmtTerm, Position> position = 
      new HashMap<SmtTerm, Position>(31);
    public HashSet<SmtTerm> seen = new HashSet<SmtTerm>(31);
    public TermBuilder<SmtTerm> term;
  }

  /** A position in a logical formula counts the parity of the number
   *  of NOT parents. */
  private static enum Position {
    POSITIVE,
    NEGATIVE,
    UNKNOWN
  }

  /** 
    Eliminates the shared parts of {@code ts}. It returns the
    modified term and the extracted parts in a pair. It uses the
    builder {@code term} to create the modified term.
   */
  public static Pair<ImmutableList<SmtTerm>, ImmutableList<SmtTerm>> eliminateSharingPair(ImmutableList<SmtTerm> ts, TermBuilder<SmtTerm> term) {
    ImmutableList.Builder<SmtTerm> newTerms = ImmutableList.builder();
    EliminateSharingContext context = new EliminateSharingContext();
    context.term = term;

    for (SmtTerm t : ts)
      countParents(t, context);

    for (SmtTerm t : ts)
     newTerms.add(unshare(t, Position.NEGATIVE, context));

    ImmutableList.Builder<SmtTerm> defs = ImmutableList.builder();
    for (Map.Entry<String, SmtTerm> vd : context.varDefs.entrySet()) {
      SmtTerm v = term.mk("var_formula", vd.getKey());
      SmtTerm od = vd.getValue();
      SmtTerm nd = context.oldToNew.get(od);
      switch (context.position.get(od)) {
      case POSITIVE:
        defs.add(term.mk("implies", v, nd));
        break;
      case NEGATIVE:
        defs.add(term.mk("implies", nd, v));
        break;
      default:
        defs.add(term.mk("iff", v, nd));
      }
    }
    return Pair.of(newTerms.build(), defs.build());
  }

  public static Pair<SmtTerm, ImmutableList<SmtTerm>> eliminateSharingPair(SmtTerm t, TermBuilder<SmtTerm> term) {
    ImmutableList.Builder<SmtTerm> singleTerm = ImmutableList.builder();
    singleTerm.add(t);
    Pair<ImmutableList<SmtTerm>, ImmutableList<SmtTerm>> p = eliminateSharingPair(singleTerm.build(), term);
    return Pair.of(p.first.get(0), p.second);
  }

  public static SmtTerm eliminateSharing(SmtTerm t, TermBuilder<SmtTerm> term) {
    ImmutableList.Builder<SmtTerm> singleTerm = ImmutableList.builder();
    singleTerm.add(t);
    Pair<ImmutableList<SmtTerm>, ImmutableList<SmtTerm>> p = eliminateSharingPair(singleTerm.build(), term);
    return term.mk("implies", term.mk("and", p.second), p.first.get(0));
  }

  private static void countParents(SmtTerm t, EliminateSharingContext context) {
    if (context.seen.contains(t)) return;
    context.seen.add(t);
    for (SmtTerm c : t.children) {
      Integer cnt = context.parentCount.get(c);
      if (cnt == null) cnt = 0;
      context.parentCount.put(c, cnt + 1);
      countParents(c, context);
    }
  }

  private static int getPrintSize(SmtTerm t, EliminateSharingContext context) {
    Integer result = context.sizes.get(t);
    if (result != null) return result;
    result = 1;
    for (SmtTerm c : t.children) result += getPrintSize(c, context);
    context.sizes.put(t, result);
    return result;
  }

  private static SmtTerm unshare(
      SmtTerm t, 
      Position p,
      EliminateSharingContext context
  ) {
    assert t != null;
    SmtTerm result = context.unshared.get(t);
    if (t.data != null) result = t;
    if (!t.sort().isSubsortOf(Sort.FORMULA)) result = t;
    for (SmtTerm c : t.children)
      if (!c.sort().isSubsortOf(Sort.FORMULA)) result = t;
    if (result != null) {
      setPosition(context, t, p);
      return result;
    }

    ImmutableList.Builder<SmtTerm> children = ImmutableList.builder();
    if ("not".equals(t.id))
      children.add(unshare(t.children.get(0), not(p), context));
    else if ("and".equals(t.id) || "or".equals(t.id))
      for (SmtTerm c : t.children) children.add(unshare(c, p, context));
    else if ("implies".equals(t.id)) {
      children.add(unshare(t.children.get(0), not(p), context));
      children.add(unshare(t.children.get(1), p, context));
    } else {
      for (SmtTerm c : t.children) 
        children.add(unshare(c, Position.UNKNOWN, context));
    }
    result = context.term.mk(t.id, children.build());

    int S = getPrintSize(result, context);
    Integer P = context.parentCount.get(t);
    if (P == null) P = 0;
    if (S * P - S - P > 2) {
      String id = Id.get("plucked");
      context.varDefs.put(id, t);
      context.oldToNew.put(t, result);
      setPosition(context, t, p);
      result = context.term.mk("var_formula", id);
    }

    context.unshared.put(t, result);
    return result;
  }

  private static void setPosition(
      EliminateSharingContext context, 
      SmtTerm t, 
      Position p
  ) {
    Position op = context.position.get(t);
    if (op == null)
      context.position.put(t, p);
    else if (op != p)
      context.position.put(t, Position.UNKNOWN);
  }

  private static Position not(Position p) {
    switch (p) {
    case POSITIVE: return Position.NEGATIVE;
    case NEGATIVE: return Position.POSITIVE;
    default: return Position.UNKNOWN;
    }
  }
}
