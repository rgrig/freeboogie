package freeboogie.vcgen;

import com.google.common.collect.ImmutableList;
import genericutils.Id;

import freeboogie.ast.*;

/** Desugars <b>while</b> statements.
  The code
    <pre>
    [L:] while (C) invariant I... { B }
    </pre>
  becomes
    <pre>
    L: assume true;
    assert/assume I;...
    if (C) {
      B;
      assert I;...
      goto L;
    }
    </pre>
  
  <p>The <tt>assert/assume I</tt> line stands for a sequence of
  commands that correspond to all the loop invariants. The free
  ones appear as assumptions, the others appear as assertions.
  The line <tt>assert I</tt> is a sequence of commands that

  <p>The label L is added if it is missing.

  <p>The body B is processed first.
 */
public class WhileDesugarer extends CommandDesugarer {
  @Override public WhileCmd eval(WhileCmd cmd) {
    ImmutableList<String> labels = cmd.labels().isEmpty()?
        ImmutableList.of(Id.get("while")) :
        cmd.labels();
    String l = labels.get(0);
    Block body = (Block) cmd.body().eval(this);
    addEquivalentCommand(AssertAssumeCmd.mk(
        labels,
        AssertAssumeCmd.CmdType.ASSUME,
        AstUtils.ids(),
        BooleanLiteral.mk(BooleanLiteral.Type.TRUE, cmd.loc()),
        cmd.loc()));
    for (LoopInvariant inv : cmd.inv()) {
      addEquivalentCommand(AssertAssumeCmd.mk(
          noString,
          inv.free()? 
              AssertAssumeCmd.CmdType.ASSUME :
              AssertAssumeCmd.CmdType.ASSERT,
          AstUtils.ids(),
          inv.expr(),
          inv.loc()));
    }
    ImmutableList.Builder<Command> ifCmds = ImmutableList.builder();
    ifCmds.addAll(body.commands());
    int bodyLen = body.commands().size();
    if (bodyLen == 0 || !(body.commands().get(bodyLen-1) instanceof GotoCmd)) {
      // The 'if' above avoids introducing unreachable commands.
      for (LoopInvariant inv : cmd.inv()) if (!inv.free()) {
        ifCmds.add(AssertAssumeCmd.mk(
            noString,
            AssertAssumeCmd.CmdType.ASSERT,
            AstUtils.ids(),
            inv.expr().clone(),
            inv.loc()));
      }
      ifCmds.add(GotoCmd.mk(noString, ImmutableList.of(l), cmd.loc()));
    }
    addEquivalentCommand(IfCmd.mk(
        noString,
        cmd.condition(),
        Block.mk(ifCmds.build(), cmd.loc()),
        null,
        cmd.loc()));
    return null;
  }
}
