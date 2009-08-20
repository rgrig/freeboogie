package freeboogie.vcgen;

import java.util.HashSet;
import java.util.logging.Logger;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Sets;
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

  @Override public Command eval(Command cmd, ImmutableList<String> labels) {
    if (toRemove.contains(Pair.of(cmd, currentFG.to(cmd).get(0)))) {
      addEquivalentCommand(cmd);
      return GotoCmd.mk(noLabel, noLabel, cmd.loc());
    }
    return cmd;
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
