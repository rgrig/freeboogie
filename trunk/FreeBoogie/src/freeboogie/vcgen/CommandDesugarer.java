package freeboogie.vcgen;

import java.util.ArrayDeque;
import java.util.HashMap;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;

import freeboogie.ast.*;

/**
  Base class for transformers that replace certain commands by
  a sequence of equivalent commands. Subclasses should call
  {@code addEquivalentCommand()} when they visit commands that
  should be replaced by something else. Some new commands may
  need fresh variables: These should be registered using {@code
  addVariable(VariableDecl)}. If a command visiting method
  returns {@code null} then only the equivalent commands are
  used; otherwise the returned value is appended after the
  equivalent commands.

  Also provides a default implementation of {@code eval(Identifier)}
  that executes substitutions registered thru {@code
  addSubstitution(IdDecl, Expr)}. The set of registered
  substitutions is reset before each command is visited.

  NOTE: relies on commands appearing only in blocks
 */
public class CommandDesugarer extends Transformer {
  // These two are used as stacks, because blocks can be nested.
  private Deque<Deque<Command>> equivCmds = 
      new ArrayDeque<Deque<Command>>();
  private Deque<HashMap<IdDecl, Expr>> toSubstitute =
      new ArrayDeque<Map<IdDecl, Expr>>();

  // These are the variables that should be added to the body.
  private ImmutableList.Builder<VariableDecl> newVars;

  // === interface for subclasses ===
  void addEquivalentCommand(Command c) {
    equivCmds.add(c);
  }

  void addSubstitution(IdDecl d, Expr e) {
    toSubstitute.put(d, e);
  }

  void addVariable(VariableDecl vd) {
    newVars.add(vd);
  }

  // === transformer methods ===

  @Override public Body eval(Body body) {
    newVars = ImmutableList.builder();
    Block nb = (Block) body.block().eval(this);
    newVars.addAll(body.vars());
    return Body.mk(newVars.build(), nb, body.loc());
  }

  @Override public Block eval(Block block) {
    toSubstitute.addFirst(Maps.newHashMap());
    equivCmds.addFirst(new ArrayDeque<Command>());
    ImmutableList.Builder<Command> newCommands = ImmutableList.builder();
    boolean same = true;
    for (Command c : block.commands()) {
      equivCmds.peekFirst().clear();
        toSubstitute.clear();
        Command nc = (Command) c.eval(this);
        newCommands.addAll(equivCmds);
        if (nc != null)  newCommands.add(nc);
        same = equivCmds.isEmpty() && nc == c;
    }
    equivCmds.removeFirst();
    toSubstitute.removeFirst();
    if (!same) block = Block.mk(newCommands.build(), block.loc());
    return block;
  }
 
  @Override public Expr eval(Identifier atomId) {
    Expr e = toSubstitute.get(tc.st().ids.def(atomId));
    return e == null? atomId : e;
  }
}

