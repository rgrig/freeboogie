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

  Also provides a default implementation of {@code eval(AtomId)}
  that executes substitutions registered thru {@code
  addSubstitution(IdDecl, Expr)}. The set of registered
  substitutions is reset before each command is visited.

  NOTE: relies on commands appearing only in blocks
 */
public class CommandDesugarer extends Transformer {
  private HashMap<IdDecl, Expr> toSubstitute = Maps.newHashMap();
  private ArrayDeque<Command> equivCmds = new ArrayDeque<Command>();
  private ImmutableList.Builder<VariableDecl> newVars;

  // shorter name to be used by subclasses
  static final ImmutableList<String> noLabel = ImmutableList.of();


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

  @Override public void see(
      Body body, 
      ImmutableList<VariableDecl> vars,
      Block block
  ) {
    newVars = ImmutableList.builder();
    Block nb = (Block) block.eval(this);
    newVars.add(vars);
    return Body.mk(newVars.build(), nb, block.loc());
  }

  @Override
  public Block eval(Block block, ImmutableList<Command> commands) {
    ImmutableList.Builder<Command> newCommands = ImmutableList.builder();
    boolean same = true;
    for (Command c : commands) {
        equivCmds.clear();
        toSubstitute.clear();
        Command nc = c.eval(this);
        newCommands.addAll(equivCmds);
        if (nc != null)  newCommands.add(nc);
        same = equivCmds.isEmpty() && nc == c;
    }
    if (!same) block = Block.mk(newCommands, block.loc());
    return block;
  }
 
  @Override
  public Expr eval(AtomId atomId, String id, ImmutableList<Type> types) {
    Expr e = toSubstitute.get(tc.st().ids.def(atomId));
    return e == null? atomId : e;
  }
}

