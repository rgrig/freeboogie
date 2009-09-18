package freeboogie.vcgen;

import java.util.ArrayDeque;
import java.util.Deque;

import com.google.common.collect.ImmutableList;
import genericutils.Id;

import freeboogie.ast.*;

/** Desugars <b>break</b> statements.
  The code here should be in agreement with the code in {@code
  FlowGraphMaker}. That is, the flowgraph before and after this
  transformation should look the "same".

  A <b>break</b> with labels is simply transformed into a
  <b>goto</b> with the same labels. A break without labels is
  transformed into a goto to the innermost <b>while</b>.

  This transformer puts labels on all <b>while</b> statements.
 */
public class BreakDesugarer extends Transformer {
  private Deque<String> whileStack = new ArrayDeque<String>();

  @Override public WhileCmd eval(WhileCmd cmd) {
    String whileLabel;
    if (!cmd.labels().isEmpty())
      whileLabel = cmd.labels().get(0);
    else
      whileLabel = Id.get("while");
    whileStack.addFirst(whileLabel);
    Block body = (Block) cmd.body().eval(this);
    whileStack.removeFirst();
    ImmutableList<String> labels = cmd.labels().isEmpty()? 
        ImmutableList.<String>of() :
        cmd.labels();
    if (labels != cmd.labels() || body != cmd.body())
      cmd = WhileCmd.mk(labels, cmd.condition(), cmd.inv(), body, cmd.loc());
    return cmd;
  }

  @Override public GotoCmd eval(BreakCmd cmd) {
    ImmutableList<String> successors = cmd.successors().isEmpty()?
        ImmutableList.of(whileStack.peekFirst()) :
        cmd.successors();
    return GotoCmd.mk(
        cmd.labels(),
        successors,
        cmd.loc());
  }
}
