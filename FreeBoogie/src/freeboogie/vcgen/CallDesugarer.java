package freeboogie.vcgen;

import java.io.PrintWriter;
import java.util.*;
import java.util.logging.Logger;

import com.google.common.collect.*;
import genericutils.Err;
import genericutils.Id;

import freeboogie.ast.*;
import freeboogie.astutil.PrettyPrinter;
import freeboogie.tc.FbError;
import freeboogie.tc.TcInterface;

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
public class CallDesugarer extends Transformer {
  private static final Logger log = Logger.getLogger("freeboogie.vcgen");

  private HashMap<VariableDecl, Expr> toSubstitute = Maps.newHashMap();
  private ArrayList<Command> equivCmds = Lists.newArrayList();

  // === transformer methods ===

  // collects new blocks
  private Deque<Block> extraBlocks = new ArrayDeque<Block>();
  @Override public Body eval(
      Body body,
      ImmutableList<VariableDecl> vars,
      ImmutableList<Block> blocks
  ) {
    boolean same = true;
    ImmutableList.Builder<Block> newBlocks = ImmutableList.builder();
    for (Block b : blocks) {
      extraBlocks.clear();
      Block nb = (Block) b.eval(this);
      same &= extraBlocks.isEmpty() && nb == b;
      newBlocks.addAll(extraBlocks).add(nb);
    }
    if (!same) body = Body.mk(vars, newBlocks.build());
    return body;
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
      block = Block.mk(nxtLabel = Id.get("call"), null, succ, block.loc());
      for (int i = equivCmds.size() - 1; i > 0; --i) {
        extraBlocks.addFirst(Block.mk(
          crtLabel = i == 0 ? name : Id.get("call"), 
          equivCmds.get(i),
          AstUtils.ids(nxtLabel),
          block.loc()));
        nxtLabel = crtLabel;
      }
    } else if (newCmd != cmd)
      block = Block.mk(name, newCmd, succ, block.loc());
    return block;
  }

  @Override public Command eval(
      CallCmd callCmd, 
      String procedure, 
      ImmutableList<Type> types, 
      ImmutableList<AtomId> results, 
      ImmutableList<Expr> args
  ) {
    toSubstitute.clear();
    equivCmds.clear();
    Procedure p = tc.st().procs.def(callCmd);
    Signature sig = p.sig();
    prepareToSubstitute(sig.results(), results);
    prepareToSubstitute(sig.args(), args);

    for (PreSpec pre : p.preconditions()) {
      equivCmds.add(AssertAssumeCmd.mk(
        AssertAssumeCmd.CmdType.ASSERT,
        ImmutableList.<AtomId>of(),
        (Expr) pre.expr().eval(this).clone(),
        callCmd.loc()));
    }
    for (ModifiesSpec m : p.modifies()) {
      equivCmds.add(HavocCmd.mk(
          AstUtils.cloneListOfAtomId(AstUtils.evalListOfAtomId(m.ids(), this)), 
          callCmd.loc()));
    }
    for (PostSpec post : p.postconditions()) {
      equivCmds.add(AssertAssumeCmd.mk(
        AssertAssumeCmd.CmdType.ASSUME,
        ImmutableList.<AtomId>of(),
        (Expr) post.expr().eval(this).clone(),
        callCmd.loc()));
    }
    toSubstitute.clear();
    return null; // TODO(rgrig): ?
  }
  
  @Override
  public Expr eval(AtomId atomId, String id, ImmutableList<Type> types) {
    Expr e = toSubstitute.get(tc.st().ids.def(atomId));
    return e == null? atomId : e;
  }

  // === helpers ===
  private void prepareToSubstitute(
      ImmutableList<VariableDecl> vars, 
      ImmutableList<? extends Expr> exprs
  ) {
    UnmodifiableIterator<VariableDecl> iv = vars.iterator();
    UnmodifiableIterator<? extends Expr> ie = exprs.iterator();
    while (iv.hasNext()) toSubstitute.put(iv.next(), ie.next());
  }
}
