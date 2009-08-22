package freeboogie.vcgen;

import java.io.PrintWriter;
import java.util.*;

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
 *    z := v / 2;
 *    return;
 *    w := z * 2;
 * }
 * </pre>
 * becomes
 * <pre>
 * implementation X(v : int) returns (w : int) {
 *     var z : int;
 *     assume v &gt; 0;
 *     z := v / 2;
 *     goto $$post;
 *     w := z * 2;
 * $$post: assert w % 2 == 0;
 * }
 * </pre>
 *
 * NOTE: Free ensures are ignored.
 */
public class SpecDesugarer extends Transformer {
  private UsageToDefMap<Implementation, Procedure> implProc;
  private UsageToDefMap<VariableDecl, VariableDecl> paramMap;
  private Map<VariableDecl, AtomId> toSubstitute = Maps.newLinkedHashMap();
  private List<Expr> preconditions = Lists.newArrayList();
  private List<Expr> postconditions = Lists.newArrayList();

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
      preconditions.add((Expr) pre.expr().eval(this).clone());
    for (PostSpec post : implProc.def(implementation).postconditions()) {
      if (!post.free()) 
        postconditions.add((Expr) post.expr().eval(this).clone());
    }

    // the rest
    toSubstitute.clear();
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
      Block block
  ) {
    ImmutableList.Builder<Command> newCommands = ImmutableList.builder();
    for (Expr e : preconditions) {
      newCommands.add(AssertAssumeCmd.mk(
          noString,
          AssertAssumeCmd.CmdType.ASSUME,
          AstUtils.ids(),
          e));
    }
    newCommands.addAll(AstUtils.evalListOfCommand(block.commands(), this));
    newCommands.add(AssertAssumeCmd.mk(
        ImmutableList.of("$$post"),
        AssertAssumeCmd.CmdType.ASSUME,
        AstUtils.ids(),
        AtomLit.mk(AtomLit.AtomType.TRUE)));
    for (Expr e : postconditions) {
      newCommands.add(AssertAssumeCmd.mk(
          noString,
          AssertAssumeCmd.CmdType.ASSERT,
          AstUtils.ids(),
          e));
    }
    newCommands.add(GotoCmd.mk(noString, noString, body.loc()));
    return Body.mk(
        vars, 
        Block.mk(newCommands.build(), block.loc()), body.loc());
  }

  @Override public GotoCmd eval(
      GotoCmd gotoCmd, 
      ImmutableList<String> labels,
      ImmutableList<String> successors
  ) {
    if (successors.isEmpty())
      return GotoCmd.mk(labels, ImmutableList.of("$$post"), gotoCmd.loc());
    return gotoCmd;
  }
}
