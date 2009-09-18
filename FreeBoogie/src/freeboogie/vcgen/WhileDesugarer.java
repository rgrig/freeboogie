package freeboogie.vcgen;

import com.google.common.collect.ImmutableList;

import freeboogie.ast.*;

/** Desugars <b>while</b> statements.
  The code
    <pre>
    L: while (C) invariant I... { B }
    </pre>
  becomes
    <pre>
    L: assume true;
    assert I;...
    if (C) {
      B;
      assert I;...
      goto L;
    }
    </pre>
  The <tt>assert I</tt> sequence appears twice so that {@code
  LoopCutter} is complete (when I is strong enough) without much
  work. 

  TODO: add labels L if not existing
  
  The body B is processed first.
 */
public class WhileDesugarer extends CommandDesugarer {
  @Override public WhileCmd eval(WhileCmd cmd) {
    String l = cmd.labels().get(0);
    Block body = (Block) cmd.body().eval(this);
    addEquivalentCommand(AssertAssumeCmd.mk(
        cmd.labels(),
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
