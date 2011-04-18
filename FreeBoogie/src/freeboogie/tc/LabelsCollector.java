// header {{{1
package freeboogie.tc;

import java.util.Map;
import java.util.Set;

import com.google.common.collect.*;

import genericutils.OneToManyBiMap;
import genericutils.Pair;

import freeboogie.ast.*;

// class LabelsCollector {{{1
/** 
  Builds, for each implementation, a 1-to-n map from commands to their labels,
  with fast lookups both ways.

  Use {@code process(program, typechecker)} to collect labels.  Find a command
  by its label using {@code command(implementation, label)}.  Find all labels
  of a command using {@code labels(implementation, command)}.  Find some
  (random) label of a command using {@code someLabel(implementation, command)}.

  You may also find all commands under a body, including those nested in other
  commands, using {@code allCommands(implementation)}.
 */
public class LabelsCollector extends Transformer {
  // fields {{{2
  private Implementation currentImplementation;

  // TODO(radugrigore): Just expose an unmodifiable view of these?
  private Map<Pair<Implementation, String>, Command> command =
      Maps.newHashMap();
  private SetMultimap<Command, String> labels = HashMultimap.create();
  private SetMultimap<Implementation, Command> allCommands =
      HashMultimap.create();

  // queries {{{2
  public Command command(Implementation implementation, String label) {
    return command.get(Pair.of(implementation, label));
  }

  public Set<String> labels(Command command) {
    return labels.get(command);
  }

  public String someLabel(Command command) {
    Set<String> labels = labels(command);
    if (labels.isEmpty()) return null;
    return labels.iterator().next();
  }

  public Set<Command> allCommands(Implementation implementation) {
    return allCommands.get(implementation);
  }

  // workers {{{2
  @Override public void see(Implementation implementation) {
    assert currentImplementation == null : "Nested implementations?";
    currentImplementation = implementation;
    implementation.body().eval(this);
    currentImplementation = null;
  }

  private void recordLabels(Command c) {
    allCommands.put(currentImplementation, c);
    for (String l : c.labels()) {
      command.put(Pair.of(currentImplementation, l), c);
      labels.put(c, l);
    }
  }

  // dispatchers {{{2
  @Override public void see(AssertAssumeCmd assertAssumeCmd) {
    recordLabels(assertAssumeCmd);
  }

  @Override public void see(AssignmentCmd assignmentCmd) {
    recordLabels(assignmentCmd);
  }

  @Override public void see(CallCmd callCmd) {
    recordLabels(callCmd);
  }

  @Override public void see(BreakCmd breakCmd) {
    recordLabels(breakCmd);
  }

  @Override public void see(GotoCmd gotoCmd) {
    recordLabels(gotoCmd);
  }

  @Override public void see(HavocCmd havocCmd) {
    recordLabels(havocCmd);
  }

  @Override public void see(IfCmd cmd) {
    recordLabels(cmd);
    cmd.yes().eval(this);
    if (cmd.no() != null) cmd.no().eval(this);
  }

  @Override public void see(WhileCmd whileCmd) {
    recordLabels(whileCmd);
    whileCmd.body().eval(this);
  }

}