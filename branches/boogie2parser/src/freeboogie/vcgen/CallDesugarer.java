package freeboogie.vcgen;

import java.util.*;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.UnmodifiableIterator;

import freeboogie.ast.*;

/**
 * Desugar call commands into a sequence of asserts, havocs, and assumes.
 *
 * Given:
 * <pre>
 * var Heap : [ref]int;
 * procedure Callee(x : int) returns (y : int);
 *   requires P(x);
 *   modifies Heap;
 *   ensures Q(x, y);
 * </pre>
 *
 * The code
 * <pre>
 * implementation Caller(v : int) returns (w : int) {
 * entry:
 *   call w := Callee(v);
 * }
 * </pre>
 * becomes
 * <pre>
 * implementation Caller(v : int) returns (w : int) {
 * entry:
 *   assert P(v);
 *   havoc Heap;
 *   assume Q(v, w);
 * }
 * </pre>
 *
 * NOTE: Free modifies are ignored.
 */
public class CallDesugarer extends CommandDesugarer {
  @Override public Command eval(
      CallCmd callCmd, 
      ImmutableList<String> labels,
      String procedure, 
      ImmutableList<Type> types, 
      ImmutableList<AtomId> results, 
      ImmutableList<Expr> args
  ) {
    Procedure p = tc.st().procs.def(callCmd);
    Signature sig = p.sig();
    prepareToSubstitute(sig.results(), results);
    prepareToSubstitute(sig.args(), args);

    for (PreSpec pre : p.preconditions()) {
      addEquivalentCommand(AssertAssumeCmd.mk(
          labels,
          AssertAssumeCmd.CmdType.ASSERT,
          ImmutableList.<AtomId>of(),
          (Expr) pre.expr().eval(this).clone(),
          callCmd.loc()));
      labels = ImmutableList.of();
    }
    for (ModifiesSpec m : p.modifies()) {
      addEquivalentCommand(HavocCmd.mk(
          labels,
          AstUtils.cloneListOfAtomId(AstUtils.evalListOfAtomId(m.ids(), this)), 
          callCmd.loc()));
      labels = ImmutableList.of();
    }
    for (PostSpec post : p.postconditions()) {
      addEquivalentCommand(AssertAssumeCmd.mk(
        labels,
        AssertAssumeCmd.CmdType.ASSUME,
        ImmutableList.<AtomId>of(),
        (Expr) post.expr().eval(this).clone(),
        callCmd.loc()));
      labels = ImmutableList.of();
    }
    if (!labels.isEmpty()) {
      addEquivalentCommand(AssertAssumeCmd.mk(
          labels,
          AssertAssumeCmd.CmdType.ASSUME,
          ImmutableList.<AtomId>of(),
          AtomLit.mk(AtomLit.AtomType.TRUE),
          callCmd.loc()));
    }
    return null;
  }
  
  // === helpers ===
  private void prepareToSubstitute(
      ImmutableList<VariableDecl> vars, 
      ImmutableList<? extends Expr> exprs
  ) {
    UnmodifiableIterator<VariableDecl> iv = vars.iterator();
    UnmodifiableIterator<? extends Expr> ie = exprs.iterator();
    while (iv.hasNext()) addSubstitution(iv.next(), ie.next());
  }
}
