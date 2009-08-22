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

  @Override public void see(
      Body body, 
      ImmutableList<VariableDecl> vars,
      Block block
  ) {
    commandByLabel = Maps.newHashMap();
    commandByBodyAndLabel.put(body, commandByLabel);
    commands = Sets.newHashSet();
    commandsByBody.put(body, commands);
    block.eval(this);
  }

  @Override public void see(
      AssertAssumeCmd assertAssumeCmd, 
      ImmutableList<String> labels,
      AssertAssumeCmd.CmdType type,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    commands.add(assertAssumeCmd);
    for (String l : labels) commandByLabel.put(l, assertAssumeCmd);
  }

  @Override public void see(
      AssignmentCmd assignmentCmd, 
      ImmutableList<String> labels,
      AtomId lhs,
      Expr rhs
  ) {
    commands.add(assignmentCmd);
    for (String l : labels) commandByLabel.put(l, assignmentCmd);
  }

  @Override public void see(
      CallCmd callCmd, 
      ImmutableList<String> labels,
      String procedure,
      ImmutableList<Type> types,
      ImmutableList<AtomId> results,
      ImmutableList<Expr> args
  ) {
    commands.add(callCmd);
    for (String l : labels) commandByLabel.put(l, callCmd);
  }

  @Override public void see(
      GotoCmd gotoCmd, 
      ImmutableList<String> labels,
      ImmutableList<String> successors
  ) {
    commands.add(gotoCmd);
    for (String l : labels) commandByLabel.put(l, gotoCmd);
  }

  @Override public void see(
      HavocCmd havocCmd, 
      ImmutableList<String> labels,
      ImmutableList<AtomId> ids
  ) {
    commands.add(havocCmd);
    for (String l : labels) commandByLabel.put(l, havocCmd);
  }

  @Override public void see(
      WhileCmd whileCmd, 
      ImmutableList<String> labels,
      Expr condition,
      ImmutableList<LoopInvariant> inv,
      Block body
  ) {
    commands.add(whileCmd);
    for (String l : labels) commandByLabel.put(l, whileCmd);
    body.eval(this);
  }
}
