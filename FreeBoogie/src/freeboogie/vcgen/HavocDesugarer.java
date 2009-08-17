package freeboogie.vcgen;

import java.util.*;
import java.util.logging.Logger;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import genericutils.*;

import freeboogie.ast.*;
import freeboogie.tc.TcInterface;
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
public class HavocDesugarer extends Transformer {
  private static final Logger log = Logger.getLogger("freeboogie.vcgen");

  private ArrayList<Command> equivCmds = Lists.newArrayList();
  private HashMap<VariableDecl, AtomId> toSubstitute = Maps.newHashMap();
  private ImmutableList.Builder<VariableDecl> newVars;

  // === transformer methods ===
  private Deque<Block> extraBlocks = new ArrayDeque<Block>();
  @Override
  public Body eval(
      Body body, 
      ImmutableList<VariableDecl> vars, 
      ImmutableList<Block> blocks
  ) {
    boolean same = true;
    ImmutableList.Builder<Block> newBlocks = ImmutableList.builder();
    newVars = ImmutableList.builder();
    for (Block b : blocks) {
      extraBlocks.clear();
      Block nb = (Block) b.eval(this);
      same &= extraBlocks.isEmpty() && nb == b;
      for (Block bb : extraBlocks) newBlocks.add(bb);
      newBlocks.add(nb);
    }
    return Body.mk(newVars.addAll(vars).build(), newBlocks.build(), body.loc());
  }

  @Override
  public Block eval(
      Block block, 
      String name, 
      Command cmd, 
      ImmutableList<AtomId> succ
  ) {
    equivCmds.clear();
    Command newCmd = AstUtils.eval(cmd, this);
    if (!equivCmds.isEmpty()) {
      String crtLabel, nxtLabel;
      block = Block.mk(nxtLabel = Id.get("havoc"), null, succ, block.loc());
      for (int i = equivCmds.size() - 1; i >= 0; --i) {
        extraBlocks.addFirst(Block.mk(
          crtLabel = i == 0 ? name : Id.get("havoc"),
          equivCmds.get(i),
          ImmutableList.of(AtomId.mk(nxtLabel, null)),
          block.loc()));
        nxtLabel = crtLabel;
      }
    } else if (newCmd != cmd)
      block = Block.mk(name, newCmd, succ, block.loc());
    return block;
  }

  @Override
  public HavocCmd eval(HavocCmd havocCmd, ImmutableList<AtomId> ids) {
    toSubstitute.clear();
    Expr e = AtomLit.mk(AtomLit.AtomType.TRUE, havocCmd.loc());
    for (AtomId id : ids) {
      VariableDecl vd = (VariableDecl)tc.st().ids.def(id);
      VariableDecl vd2 = tc.paramMap().def(vd);
      if (vd2 != null) vd = vd2;
      AtomId fresh = AtomId.mk(Id.get("fresh"), null, id.loc());
      toSubstitute.put(vd, fresh);
      equivCmds.add(AssignmentCmd.mk(id, fresh, havocCmd.loc()));
      if (vd.type() instanceof DepType) {
        Expr p = ((DepType)vd.type()).pred();
        e = BinaryOp.mk(
            BinaryOp.Op.AND, 
            e, 
            (Expr)p.eval(this).clone(), 
            p.loc());
      }
      newVars.add(VariableDecl.mk(
        ImmutableList.<Attribute>of(),
        fresh.id(),
        TypeUtils.stripDep(vd.type()).clone(),
        AstUtils.cloneListOfAtomId(vd.typeArgs())));
    }
    equivCmds.add(AssertAssumeCmd.mk(
      AssertAssumeCmd.CmdType.ASSUME,
      null,
      e,
      havocCmd.loc()));
    toSubstitute.clear();
    return null;
  }

  @Override
  public AtomId eval(AtomId atomId, String id, ImmutableList<Type> types) {
    Declaration d = tc.st().ids.def(atomId);
    AtomId r = toSubstitute.get(d);
    return r == null? atomId : r.clone();
  }

 
}

