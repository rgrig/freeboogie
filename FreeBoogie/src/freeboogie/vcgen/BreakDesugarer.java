package freeboogie.vcgen;

import java.util.Map;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;
import genericutils.Id;
import genericutils.SimpleGraph;

import freeboogie.ast.*;

/** Desugars <b>break</b> statements.
  
  Each <b>break</b> command is equivalent to a <b>goto</b>
  command whose targets are given by the flowgraph. This
  transformer may introduce extra labels.
 */
public class BreakDesugarer extends Transformer {
  private Map<Command, String> label = Maps.newHashMap();
  private SimpleGraph<Command> flowgraph;

  // BEGIN the interesting part {{{
  @Override public Body eval(Body body) {
    label.clear();
    flowgraph = tc.flowGraph(body);
    Block block = (Block) body.block().eval(this);
    if (block != body.block())
      body = Body.mk(body.vars(), block, body.loc());
    return body;
  }

  private ImmutableList<String> getLabels(Command cmd)
  {
    if (!cmd.labels().isEmpty()) return cmd.labels();
    String l = label.get(cmd);
    if (l == null) {
      for (Command c : flowgraph.from(cmd)) if (c instanceof BreakCmd) {
        l = Id.get("break");
        label.put(cmd, l);
        break;
      }
    }
    return l == null ? cmd.labels() : ImmutableList.of(l);
  }

  @Override public GotoCmd eval(BreakCmd cmd) {
    ImmutableList.Builder<String> successors = ImmutableList.builder();
    for (Command c : flowgraph.to(cmd)) {
      String l = label.get(c);
      if (l == null) {
        l = Id.get("break");
        label.put(c, l);
      }
      successors.add(l);
    }
    return GotoCmd.mk(getLabels(cmd), successors.build(), cmd.loc());
  }
  // END the interesting part }}}

  // BEGIN update labels {{{
  @Override public AssertAssumeCmd eval(AssertAssumeCmd cmd) {
    ImmutableList<String> labels = getLabels(cmd);
    if (labels != cmd.labels()) {
      cmd = AssertAssumeCmd.mk(
          labels,
          cmd.type(),
          cmd.typeArgs(),
          cmd.expr(),
          cmd.loc());
    }
    return cmd;
  }

  @Override public AssignmentCmd eval(AssignmentCmd cmd) {
    ImmutableList<String> labels = getLabels(cmd);
    if (labels != cmd.labels()) {
      cmd = AssignmentCmd.mk(
          labels,
          cmd.assignments(),
          cmd.loc());
    }
    return cmd;
  }

  @Override public CallCmd eval(CallCmd cmd) {
    ImmutableList<String> labels = getLabels(cmd);
    if (labels != cmd.labels()) {
      cmd = CallCmd.mk(
          labels,
          cmd.procedure(),
          cmd.types(),
          cmd.results(),
          cmd.args(),
          cmd.loc());
    }
    return cmd;
  }

  @Override public GotoCmd eval(GotoCmd cmd) {
    ImmutableList<String> labels = getLabels(cmd);
    if (labels != cmd.labels()) {
      cmd = GotoCmd.mk(
          labels,
          cmd.successors(),
          cmd.loc());
    }
    return cmd;
  }

  @Override public HavocCmd eval(HavocCmd cmd) {
    ImmutableList<String> labels = getLabels(cmd);
    if (labels != cmd.labels()) {
      cmd = HavocCmd.mk(
          labels,
          cmd.ids(),
          cmd.loc());
    }
    return cmd;
  }

  @Override public IfCmd eval(IfCmd cmd) {
    ImmutableList<String> labels = getLabels(cmd);
    Block yes = (Block) cmd.yes().eval(this);
    Block no = cmd.no() == null? null : (Block) cmd.no().eval(this);
    if (labels != cmd.labels() || yes != cmd.yes() || no != cmd.no()) {
      cmd = IfCmd.mk(
          labels,
          cmd.condition(),
          yes,
          no,
          cmd.loc());
    }
    return cmd;
  }

  @Override public WhileCmd eval(WhileCmd cmd) {
    ImmutableList<String> labels = getLabels(cmd);
    Block body = (Block) cmd.body().eval(this);
    if (labels != cmd.labels() || body != cmd.body()) {
      cmd = WhileCmd.mk(
          labels,
          cmd.condition(),
          cmd.inv(),
          body,
          cmd.loc());
    }
    return cmd;
  }
  // END update labels }}}
}
