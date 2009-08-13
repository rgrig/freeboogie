package freeboogie.vcgen;

import java.io.PrintWriter;
import java.util.*;
import java.util.logging.Logger;

import com.google.common.collect.*;
import genericutils.*;

import freeboogie.ast.*;
import freeboogie.astutil.PrettyPrinter;
import freeboogie.tc.*;

/**
 * For each implementation inserts assumes and assert corresponding
 * to the preconditions and postconditions of the procedure.
 *
 * Given:
 * <pre>
 * procedure X(x : int) returns (y : int);
 *   requires x &gt; 0;
 *   ensures y % 2 == 0;
 * </pre>
 *
 * The code
 * <pre>
 * implementation X(v : int) returns (w : int) {
 *    var z : int;
 * a: z := v / 2; goto b;
 * b: w := z * 2;
 * }
 * </pre>
 * becomes
 * <pre>
 * implementation X(v : int) returns (w : int) {
 *       var z : int;
 * pre:  assume v &gt; 0; goto a;
 * a:    z := v / 2;      goto b;
 * b:    w := z * 2;      goto post;
 * post: assert w % 2 == 0;
 * }
 * </pre>
 *
 * NOTE: Free ensures are ignored.
 *
 * TODO: Take care of generics.
 */
public class SpecDesugarer extends Transformer {
  private static final Logger log = Logger.getLogger("freeboogie.vcgen");

  private UsageToDefMap<Implementation, Procedure> implProc;
  private UsageToDefMap<VariableDecl, VariableDecl> paramMap;
  private Map<VariableDecl, AtomId> toSubstitute = Maps.newLinkedHashMap();
  private List<Expr> preconditions = Lists.newArrayList();
  private List<Expr> postconditions = Lists.newArrayList();

  private String afterBody;

  /** Transforms the {@code ast} and updates the typechecker. */
  @Override
  public Program process(Program p, TcInterface tc) {
    this.tc = tc; 
    implProc = tc.implProc();
    paramMap = tc.paramMap();
    p = (Program) p.eval(this);
    return TypeUtils.internalTypecheck(p, tc);
  }

  @Override
  public Implementation eval(
    Implementation implementation,
    ImmutableList<Attribute> attr,
    Signature sig,
    Body body
  ) {
    // prepare substitutions to be applied to preconditions and postconditions
    toSubstitute.clear();
    for (VariableDecl ad : sig.args()) {
      toSubstitute.put(
          paramMap.def(ad), 
          AtomId.mk(ad.name(), ImmutableList.<Type>of()));
    }
    for (VariableDecl rd : sig.results()) {
      toSubstitute.put(
          paramMap.def(rd), 
          AtomId.mk(rd.name(), ImmutableList.<Type>of()));
    }

    // collect preconditions and postconditions
    preconditions.clear();
    postconditions.clear();
    for (PreSpec pre : implProc.def(implementation).preconditions())
      preconditions.add(pre.expr());
    for (PostSpec post : implProc.def(implementation).postconditions())
      if (!post.free()) postconditions.add(post.expr());
    toSubstitute.clear();

    // the rest
    Body newBody = (Body)body.eval(this);
    if (newBody != body) {
      implementation = Implementation.mk(
          attr, 
          sig, 
          newBody, 
          implementation.loc());
    }
    return implementation;
  }

  @Override
  public AtomId eval(AtomId atomId, String id, ImmutableList<Type> types) {
    IdDecl d = tc.st().ids.def(atomId);
    AtomId s = toSubstitute.get(d);
    return s == null? atomId : s.clone();
  }

  @Override
  public Body eval(
      Body body, 
      ImmutableList<VariableDecl> vars,
      ImmutableList<Block> blocks
  ) {
    // newBlocks is built backwards
    Deque<Block> newBlocks = new ArrayDeque<Block>();
    String nextLabel, currentLabel;
    Block b;
    newBlocks.addFirst(b = Block.mk(
        nextLabel = Id.get("exit"), 
        null, 
        ImmutableList.<AtomId>of()));
    for (Expr e : Iterables.reverse(postconditions)) {
      newBlocks.addFirst(b = Block.mk(
          currentLabel = Id.get("post"),
          AssertAssumeCmd.mk(
              AssertAssumeCmd.CmdType.ASSERT, 
              ImmutableList.<AtomId>of(), 
              e),
          AstUtils.ids(nextLabel)));
      nextLabel = currentLabel;
    }
    afterBody = nextLabel; // used by the eval* call on the next line
    for (Block ob : Iterables.reverse(AstUtils.evalListOfBlock(blocks, this))) {
      newBlocks.addFirst(ob);
      nextLabel = ob.name();
    }
    for (Expr e : Iterables.reverse(preconditions)) {
      newBlocks.addFirst(b = Block.mk(
          currentLabel = Id.get("pre"),
          AssertAssumeCmd.mk(
              AssertAssumeCmd.CmdType.ASSUME,
              ImmutableList.<AtomId>of(),
              e),
          AstUtils.ids(nextLabel)));
      nextLabel = currentLabel;
    }
    return Body.mk(vars, ImmutableList.copyOf(newBlocks));
  }

  @Override
  public Block eval(
      Block block, 
      String name, 
      Command cmd, 
      ImmutableList<AtomId> succ
  ) {
    if (succ.isEmpty())
      block = Block.mk(name, cmd, AstUtils.ids(afterBody));
    return block;
  }
}
