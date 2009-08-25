package freeboogie.vcgen;

import java.util.*;

import com.google.common.collect.ImmutableList;
import genericutils.*;

import freeboogie.ast.*;
import freeboogie.tc.SymbolTable;

/**
 * Finds what identifiers appear in an expression and in what context.
 *
 * The call {@code ast.eval(rwsf)} returns a pair of {@code CSeq}
 * that contain the identifiers appearing in read context and those
 * that appear in write contexts. 
 *
 * NOTE: You can turn the {@code CSeq} into a set by iterating and
 * building a {@code HashSet}.
 */
public class ReadWriteSetFinder 
extends AssociativeEvaluator<Pair<CSeq<VariableDecl>,CSeq<VariableDecl>>> {
  private SymbolTable st;
  private Deque<Boolean> context; // true = write, false = read

  public ReadWriteSetFinder(SymbolTable st) { 
    super(new PairAssocOp<CSeq<VariableDecl>,CSeq<VariableDecl>>(
      new CSeqAcc<VariableDecl>(), new CSeqAcc<VariableDecl>())); 
    this.st = st;
    context = new ArrayDeque<Boolean>();
    context.addFirst(false);
  }
 
  @Override public Pair<CSeq<VariableDecl>, CSeq<VariableDecl>>
  eval(Identifier atomId) {
    IdDecl d = st.ids.def(atomId);
    CSeq<VariableDecl> r, w;
    r = w = CSeq.mk();
    if (d instanceof VariableDecl) {
      VariableDecl vd = (VariableDecl) d;
      if (context.getFirst()) w = CSeq.mk(vd);
      else r = CSeq.mk(vd);
    }
    return memo(atomId, Pair.of(r, w));
  }

  @Override public Pair<CSeq<VariableDecl>, CSeq<VariableDecl>>
  eval(CallCmd callCmd) {
    assert !context.getFirst();
    Pair<CSeq<VariableDecl>, CSeq<VariableDecl>> r = assocOp.zero();
    context.addFirst(true);
    for (Identifier id : callCmd.results()) r = assocOp.plus(r, id.eval(this));
    context.removeFirst();
    for (Expr e : callCmd.args()) r = assocOp.plus(r, e.eval(this));
    return memo(callCmd, r);
  }

  @Override public Pair<CSeq<VariableDecl>, CSeq<VariableDecl>>
  eval(OneAssignment oneAssignment) {
    assert !context.getFirst();
    Pair<CSeq<VariableDecl>, CSeq<VariableDecl>> r = assocOp.zero();
    context.addFirst(true);
    r = assocOp.plus(r, oneAssignment.lhs().eval(this));
    context.removeFirst();
    r = assocOp.plus(r, oneAssignment.rhs().eval(this));
    return memo(oneAssignment, r);
  }

  @Override public Pair<CSeq<VariableDecl>, CSeq<VariableDecl>>
  eval(HavocCmd havocCmd) {
    assert !context.getFirst();
    Pair<CSeq<VariableDecl>, CSeq<VariableDecl>> r = assocOp.zero();
    context.addFirst(true);
    for (Identifier id : havocCmd.ids()) r = assocOp.plus(r, id.eval(this));
    context.removeFirst();
    return memo(havocCmd, r);
  }

  @Override public Pair<CSeq<VariableDecl>, CSeq<VariableDecl>>
  eval(MapSelect atomIdx) {
    Pair<CSeq<VariableDecl>, CSeq<VariableDecl>> r = assocOp.zero();
    r = assocOp.plus(r, atomIdx.map().eval(this));
    context.addFirst(false);
    for (Expr e : atomIdx.idx()) r = assocOp.plus(r, e.eval(this));
    context.removeFirst();
    return memo(atomIdx, r);
  }
}
