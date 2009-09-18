package freeboogie.vcgen;

import com.google.common.collect.ImmutableList;
import genericutils.Id;

import freeboogie.ast.*;

/** Replaces <b>if</b> statements by <b>assume</b> statements.
  The code
    <pre>
    if (C) { Y } else { N }
    </pre>
  becomes
    <pre>
    goto L1, L2;
    L1: assume C;
        Y
        goto L3;
    L2: assume !C;
        N
    L3: assume true;
    </pre>
  
  <p>Note that both Y and N may be empty, and N may be missing
  completely, which is equivalent to being empty. If C is a
  wildcard then the statements at L1 and L2 are both <tt>assume
  true</tt>.

  <p>The <b>if</b> statements in Y and N are processed first.
 */
public class IfDesugarer extends CommandDesugarer {
  @Override public IfCmd eval(IfCmd cmd) {
    Block yes = (Block) cmd.yes().eval(this);
    Block no = Block.mk(ImmutableList.<Command>of(), cmd.loc());
    if (cmd.no() != null) no = (Block) cmd.no().eval(this);
    String l1 = Id.get("if");
    String l2 = Id.get("if");
    String l3 = Id.get("if");
    addEquivalentCommand(GotoCmd.mk(
        cmd.labels(), 
        ImmutableList.of(l1, l2),
        cmd.loc()));
    addEquivalentCommand(AssertAssumeCmd.mk(
        ImmutableList.of(l1),
        AssertAssumeCmd.CmdType.ASSUME,
        AstUtils.ids(),
        cmd.condition().clone(),
        cmd.loc()));
    for (Command c : yes.commands())
      addEquivalentCommand(c);
    addEquivalentCommand(GotoCmd.mk(
        noString,
        ImmutableList.of(l3),
        cmd.loc()));
    addEquivalentCommand(AssertAssumeCmd.mk(
        ImmutableList.of(l2),
        AssertAssumeCmd.CmdType.ASSUME,
        AstUtils.ids(),
        UnaryOp.mk(UnaryOp.Op.NOT, cmd.condition()),
        cmd.loc()));
    for (Command c : no.commands())
      addEquivalentCommand(c);
    addEquivalentCommand(AssertAssumeCmd.mk(
        ImmutableList.of(l3),
        AssertAssumeCmd.CmdType.ASSUME,
        AstUtils.ids(),
        BooleanLiteral.mk(BooleanLiteral.Type.TRUE, cmd.loc()),
        cmd.loc()));
    return null;
  }
}
