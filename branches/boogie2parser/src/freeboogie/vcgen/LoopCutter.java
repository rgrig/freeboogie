package freeboogie.vcgen;

import java.util.HashSet;
import java.util.Set;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Sets;
import genericutils.Err;
import genericutils.Pair;
import genericutils.SimpleGraph;

import freeboogie.ast.*;

/**
 * Cuts back edges and removes unreachable commands. (Back edges
 * according to some arbitrary DFS.)
 */
public class LoopCutter extends CommandDesugarer {
  private SimpleGraph<Command> currentFG;

  private HashSet<Command> seen = Sets.newHashSet();
  private HashSet<Command> done = Sets.newHashSet();
  private HashSet<Pair<Command, Command>> toRemove = Sets.newHashSet();
  private boolean hasStuck;

  // === transformer methods ===

  @Override public Body eval(
      Body body,
      ImmutableList<VariableDecl> vars,
      Block block
  ) {
    seen.clear();
    done.clear();
    toRemove.clear();
    currentFG = tc.flowGraph(body);
    dfs(block.commands().get(0));
    block = (Block) block.eval(this);
    return Body.mk(vars, block, body.loc());
  }


  @Override public GotoCmd eval(
      GotoCmd cmd, 
      ImmutableList<String> labels,
      ImmutableList<String> successors
  ) {
    ImmutableList.Builder<String> newSuccessors = ImmutableList.builder();
    for (Command c : currentFG.to(cmd)) {
      if (!toRemove.contains(Pair.of(cmd, c))) 
        newSuccessors.add(c.labels().get(0));
    }
    return GotoCmd.mk(labels, newSuccessors.build(), cmd.loc());
  }

  @Override public Command eval(
      AssertAssumeCmd assertAssumeCmd, 
      ImmutableList<String> labels,
      AssertAssumeCmd.CmdType type,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    return processCommand(assertAssumeCmd);
  }

  @Override public Command eval(
      AssignmentCmd assignmentCmd, 
      ImmutableList<String> labels,
      AtomId lhs,
      Expr rhs
  ) {
    return processCommand(assignmentCmd);
  }

  @Override public Command eval(
      CallCmd callCmd, 
      ImmutableList<String> labels,
      String procedure,
      ImmutableList<Type> types,
      ImmutableList<AtomId> results,
      ImmutableList<Expr> args
  ) {
    return processCommand(callCmd);
  }

  @Override public Command eval(
      HavocCmd havocCmd, 
      ImmutableList<String> labels,
      ImmutableList<AtomId> ids
  ) {
    return processCommand(havocCmd);
  }

  private Command processCommand(Command command) {
    Set<Command> next = currentFG.to(command);
    assert next.size() == 1;
    if (toRemove.contains(Pair.of(command, next.iterator().next()))) {
      addEquivalentCommand(command);
      return GotoCmd.mk(noString, noString, command.loc());
    }
    return command;
  }

  @Override public void see(
      WhileCmd whileCmd, 
      ImmutableList<String> labels,
      Expr condition,
      ImmutableList<LoopInvariant> inv,
      Block body
  ) {
    Err.internal("While commands should have been desugared.");
  }

  // === depth first search for back edges ===

  private void dfs(Command b) {
    seen.add(b);
    for (Command c : currentFG.to(b)) {
      if (done.contains(c)) continue;
      if (seen.contains(c))
        toRemove.add(Pair.of(b, c));
      else
        dfs(c);
    }
    done.add(b);
  }
}
