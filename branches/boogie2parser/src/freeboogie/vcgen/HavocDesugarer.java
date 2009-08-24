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
 * @see freeboogie.vcgen.VcGenerator
 */
public class HavocDesugarer extends CommandDesugarer {
  @Override public HavocCmd eval(HavocCmd havocCmd) {
    Expr e = AtomLit.mk(AtomLit.AtomType.TRUE, havocCmd.loc());
    for (AtomId id : havocCmd.ids()) {
      VariableDecl vd = (VariableDecl)tc.st().ids.def(id);
      VariableDecl vd2 = tc.paramMap().def(vd);
      if (vd2 != null) vd = vd2;
      AtomId fresh = AtomId.mk(
          Id.get("fresh"), 
          ImmutableList.<Type>of(), 
          id.loc());
      addSubstitution(vd, fresh);
      addEquivalentCommand(AssignmentCmd.mk(
          havocCmd.labels(), 
          id, 
          fresh, 
          havocCmd.loc()));
      /* TODO (radugrigore): use the 'where' part of vd
      if (vd.type() instanceof DepType) {
        Expr p = ((DepType) vd.type()).pred();
        e = BinaryOp.mk(
            BinaryOp.Op.AND, 
            e, 
            (Expr)p.eval(this).clone(), 
            p.loc()); 
      }*/
      addVariable(VariableDecl.mk(
          ImmutableList.<Attribute>of(),
          fresh.id(),
          vd.type().clone(),
          AstUtils.cloneListOfAtomId(vd.typeArgs()),
          null));
    }
    addEquivalentCommand(AssertAssumeCmd.mk(
        noString,
        AssertAssumeCmd.CmdType.ASSUME,
        ImmutableList.<AtomId>of(),
        e,
        havocCmd.loc()));
    return null;
  }
}

