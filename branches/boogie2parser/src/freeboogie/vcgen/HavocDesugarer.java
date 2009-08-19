package freeboogie.vcgen;

import java.util.*;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import genericutils.*;

import freeboogie.ast.*;
import freeboogie.tc.TypeUtils;

/**
 * Desugar havoc commands into assignments from fresh variables.
 *
 * The code
 * <pre>
 * implementation I() returns (x : int where P(x)) {
 *   var y : int where Q(x, y);
 * entry:
 *   havoc x;
 *   havoc y;
 * }
 * </pre>
 * becomes
 * <pre>
 * implementation I() returns (x : int where P(x)) {
 *   var x$fresh : int;
 *   var y$fresh : int;
 *   var y where Q(x, y);
 * entry:
 *   x := x$fresh; assume P(x$fresh);
 *   y := y$fresh; assume Q(x, y$fresh);
 * }
 * </pre>
 *
 * Note that the place of the assume commands is relevant since
 * the program is not yet passive. A subsequent phase will get rid
 * of the other <b>where</b> clauses.
 *
 * TODO This is a bit too similar to call desugarer. Try to factor out code.
 *
 * @see freeboogie.vcgen.VcGenerator
 */
public class HavocDesugarer extends CommandDesugarer {
  @Override
  public HavocCmd eval(HavocCmd havocCmd, ImmutableList<AtomId> ids) {
    Expr e = AtomLit.mk(AtomLit.AtomType.TRUE, havocCmd.loc());
    for (AtomId id : ids) {
      VariableDecl vd = (VariableDecl)tc.st().ids.def(id);
      VariableDecl vd2 = tc.paramMap().def(vd);
      if (vd2 != null) vd = vd2;
      AtomId fresh = AtomId.mk(Id.get("fresh"), null, id.loc());
      addSubstitution(vd, fresh);
      addEquivalentCommand(AssignmentCmd.mk(id, fresh, havocCmd.loc()));
      if (vd.type() instanceof DepType) {
        Expr p = ((DepType) vd.type()).pred();
        e = BinaryOp.mk(
            BinaryOp.Op.AND, 
            e, 
            (Expr)p.eval(this).clone(), 
            p.loc());
      }
      addVariable(VariableDecl.mk(
        ImmutableList.<Attribute>of(),
        fresh.id(),
        TypeUtils.stripDep(vd.type()).clone(),
        AstUtils.cloneListOfAtomId(vd.typeArgs())));
    }
    addEquivalentCommand(AssertAssumeCmd.mk(
      AssertAssumeCmd.CmdType.ASSUME,
      ImmutableList.<AtomId>of(),
      e,
      havocCmd.loc()));
    return null;
  }
}

