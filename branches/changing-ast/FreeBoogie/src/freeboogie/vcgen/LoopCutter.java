package freeboogie.vcgen;

import java.util.HashSet;
import java.util.logging.Logger;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Sets;
import genericutils.*;

import freeboogie.ast.*;
import freeboogie.tc.TcInterface;
import freeboogie.tc.TypeUtils;

/**
 * Cuts back edges and removes unreachable blocks. (Back edges
 * according to some arbitrary DFS.)
 */
public class LoopCutter extends Transformer {
  private static final Logger log = Logger.getLogger("freeboogie.vcgen");

  private SimpleGraph<Block> currentFG;

  private HashSet<Block> seen = Sets.newHashSet();
  private HashSet<Block> done = Sets.newHashSet();
  private HashSet<Pair<Block, String>> toRemove = Sets.newHashSet();
  private String stuckName;
  private boolean hasStuck;

  // === transformer methods ===

  @Override
  public Implementation eval(
    Implementation implementation,
    ImmutableList<Attribute> attr,
    Signature sig,
    Body body
  ) {
    currentFG = tc.getFlowGraph(implementation);
    seen.clear(); done.clear(); toRemove.clear();
    dfs(body.blocks());
    hasStuck = false;
    stuckName = Id.get("stuck");
    Body newBody = (Body)body.eval(this);
    if (newBody != body)
      implementation = Implementation.mk(attr, sig, newBody);
    return implementation;
  }

  @Override public Body eval(
      Body body,
      ImmutableList<VariableDecl> vars,
      ImmutableList<Block> blocks
  ) {
    boolean same = true;
    ImmutableList.Builder<Block> newBlocks = ImmutableList.builder();
    for (Block b : blocks) {
      if (seen.contains(b)) {
        Block nb = (Block) b.eval(this);
        same &= nb == b;
        newBlocks.add(nb);
      } else same = false;
    }
    if (hasStuck) {
      same = false;
      newBlocks.add(Block.mk(
          stuckName,
          AssertAssumeCmd.mk(
            AssertAssumeCmd.CmdType.ASSUME,
            null,
            AtomLit.mk(AtomLit.AtomType.FALSE)),
          ImmutableList.of()));
    }
    if (!same) body = Body.mk(vars, newBlocks.builder(), body.loc());
    return body;
  }

  @Override
  public Block eval(
      Block block, 
      String name, 
      Command cmd, 
      ImmutableList<AtomId> succ
  ) {
    Pair<Block, String> pair = Pair.of(block, null);
    int newSuccSize = 0;
    ImmutableList.Builder<AtomId> newSucc = ImmutableList.builder();
    for (AtomId s : succ) {
      pair.second = s.id();
      if (!toRemove.contains(pair)) {
        newSucc.add(AtomId.mk(s));
        ++newSuccSize;
      }
    }
    if (!succ.isEmpty() && newSuccSize == 0) {
      hasStuck = true;
      newSucc.add(AtomId.mk(stuckName, null));
    }
    if (succ.size() != newSuccSize)
      block = Block.mk(name, cmd, newSucc.build(), block.loc());
    return block;
  }

  // === depth first search for back edges ===

  private void dfs(Block b) {
    if (b == null) return;
    seen.add(b);
    for (Block c : currentFG.to(b)) {
      if (done.contains(c)) continue;
      if (seen.contains(c))
        toRemove.add(Pair.of(b, c.getName()));
      else
        dfs(c);
    }
    done.add(b);
  }
}
