package freeboogie.vcgen;

import java.io.PrintWriter;
import java.util.*;
import java.util.logging.Logger;

import com.google.common.collect.ImmutableList;
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
  private ArrayList<Expr> preconditions = Lists.newArrayList();
  private ArrayList<Expr> postconditions = Lists.newArrayList();
  private ArrayList<ImmutableList<AtomId>> havocs = Lists.newArrayList();
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
    if (!same) block = Block.mk(vars, newBlocks.build());
    return block;
  }

  @Override
  public Block eval(
      Block block, 
      String name, 
      Command cmd, 
      ImmutableList<AtomId> succ
  ) {
    equivCmds.clear();
    Command newCmd = cmd == null? null : (Command) cmd.eval(this);
    if (!equivCmds.isEmpty()) {
      String crtLabel, nxtLabel;
      block = Block.mk(nxtLabel = Id.get("call"), null, succ, block.loc());
      for (int i = equivCmds.size() - 1; i > 0; --i) {
        extraBlocks.addFirst(Block.mk(
          i == 0 ? name :crtLabel = Id.get("call"), 
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
  public Command eval(
      CallCmd callCmd, 
      String procedure, 
      ImmutableList<Type> types, 
      ImmutableList<AtomId> results, 
      ImmutableList<Expr> args
  ) {
    toSubstitute.clear();
    preconditions.clear();
    postconditions.clear();
    havocs.clear();
    equivCmds.clear();
    Procedure p = tc.st().procs.def(callCmd);
    Signature sig = p.sig();
    VariableDecl rv = (VariableDecl) sig.results();
    if (!results.isEmpty()) havocs.add(results.clone());
    while (rv != null) {
      toSubstitute.put(rv, results.getId());
      rv = (VariableDecl)rv.getTail();
      results = results.getTail();
    }
    VariableDecl av = (VariableDecl)sig.getArgs();
    while (av != null) {
      toSubstitute.put(av, args.getExpr());
      av = (VariableDecl)av.getTail();
      args = args.getTail();
    }
    Specification spec = p.getSpec();
    while (spec != null) {
      Expr se = (Expr)spec.getExpr().eval(this).clone();
      switch (spec.getType()) {
      case REQUIRES:  
        preconditions.add(se); break;
      case ENSURES:
        postconditions.add(se); break;
      case MODIFIES:
        if (!spec.getFree()) {
          Identifiers ids = null;
          Exprs e = (Exprs)se;
          while (e != null) {
            ids = Identifiers.mk((AtomId)e.getExpr(), ids, e.getExpr().loc());
            e = e.getTail();
          }
          havocs.add(ids); 
        }
        break;
      default:
        assert false;
      }
      spec = spec.getTail();
    }
    for (Expr pre : preconditions) {
      equivCmds.add(AssertAssumeCmd.mk(
        AssertAssumeCmd.CmdType.ASSERT,
        null,
        pre,
        callCmd.loc()));
    }
    for (Identifiers h : havocs)
      equivCmds.add(HavocCmd.mk(h, callCmd.loc()));
    for (Expr post : postconditions) {
      equivCmds.add(AssertAssumeCmd.mk(
        AssertAssumeCmd.CmdType.ASSUME,
        null,
        post,
        callCmd.loc()));
    }
    toSubstitute.clear();
    return null;
  }
  
  @Override
  public Expr eval(AtomId atomId, String id, ImmutableList<Type> types) {
    Expr e = toSubstitute.get(tc.st().ids.def(atomId));
    return e == null? atomId : e;
  }
}
