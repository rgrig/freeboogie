package freeboogie.tc;

import java.util.Map;
import java.util.Set;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import freeboogie.ast.*;

/** 
  Builds a map from labels to their commands. 

  After a call to {@code process(program, typechecker)} the
  client can fetch a command from a body and a label using {@code
  getCommand()} and can also fetch a set of all commands in a
  body using {@code getAllCommands()}.
 */
public class LabelsCollector extends Transformer {
  private Map<Body, Map<String, Command>> commandByBodyAndLabel = 
      Maps.newHashMap();
  private Map<String, Command> commandByLabel;

  private Map<Body, Set<Command>> commandsByBody = Maps.newHashMap();
  private Set<Command> commands;

  public Command getCommand(Body body, String label) {
    return commandByBodyAndLabel.get(body).get(label);
  }

  public Set<Command> getAllCommands(Body body) {
    return Sets.newHashSet(commandsByBody.get(body));
  }

  @Override public void see(Body body) {
    Block block = body.block();
    commandByLabel = Maps.newHashMap();
    commandByBodyAndLabel.put(body, commandByLabel);
    commands = Sets.newHashSet();
    commandsByBody.put(body, commands);
    block.eval(this);
  }

  @Override public void see(AssertAssumeCmd assertAssumeCmd) {
    recordLabels(assertAssumeCmd);
  }

  @Override public void see(AssignmentCmd assignmentCmd) {
    recordLabels(assignmentCmd);
  }

  @Override public void see(CallCmd callCmd) {
    recordLabels(callCmd);
  }

  @Override public void see(GotoCmd gotoCmd) {
    recordLabels(gotoCmd);
  }

  @Override public void see(HavocCmd havocCmd) {
    recordLabels(havocCmd);
  }

  @Override public void see(WhileCmd whileCmd) {
    recordLabels(whileCmd);
    whileCmd.body().eval(this);
  }

  private void recordLabels(Command c) {
    commands.add(c);
    for (String l : c.labels()) commandByLabel.put(l,c);
  }
}
