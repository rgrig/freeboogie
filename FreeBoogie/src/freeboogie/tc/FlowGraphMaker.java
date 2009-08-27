package freeboogie.tc;

import java.util.*;

import com.google.common.collect.*;
import genericutils.Err;
import genericutils.SimpleGraph;

import freeboogie.ast.*;

/**
  Constructs a flowgraph of blocks for each implementation.

  After {@code process(ast)} you can ask {@code flowGraph(body)}
  to get a {@code SimpleGraph&lt;Command&gt;}. Processing
  checks for inexistent labels and reports a list of errors.
  Unreachability warnings are printed.

  @author rgrig
 */
public class FlowGraphMaker extends Transformer {
  // Connects labels to commands.
  private LabelsCollector labelsCollector;

  // A stack with next commands within each nested block.
  private ArrayDeque<Command> nextCommand = new ArrayDeque<Command>();
  
  // the flow graph currently being built
  private SimpleGraph<Command> currentFlowGraph;
  
  private Body currentBody;

  // maps bodies to their flowgraphs
  private HashMap<Body, SimpleGraph<Command>> flowGraphs;
  
  // the detected problems 
  private List<FbError> errors;
  
  // used for reachability (DFS)
  private HashSet<Command> seenCommands = Sets.newHashSet();
 
  // === public interface ===
  
  /**
   * Constructs flow graphs for {@code ast}. It also prints warnings
   * if there are syntactically unreachable blocks. 
   * @param ast the AST for which to build flow graphs
   * @return the detected problems 
   */
  public List<FbError> process(Program ast) {
    nextCommand.clear();
    labelsCollector = new LabelsCollector();
    errors = Lists.newArrayList();
    flowGraphs = Maps.newHashMap();
    ast.eval(labelsCollector); // collect labels
    ast.eval(this);   // build the graph
    for (SimpleGraph<Command> fg : flowGraphs.values())
      fg.freeze();
    return errors;
  }


  /** Returns the command flow graph for {@code body}. */
  public SimpleGraph<Command> flowGraph(Body body) {
    return flowGraphs.get(body);
  }
  
  // === helpers ===
  
  private void dfs(Command c) {
    if (seenCommands.contains(c)) return;
    seenCommands.add(c);
    Set<Command> children = currentFlowGraph.to(c);
    for (Command d : children) dfs(d); 
  }
  
  // BEGIN top-level methods {{{
  @Override public void see(Body body) {
    // initialize graph
    currentFlowGraph = new SimpleGraph<Command>();
    flowGraphs.put(body, currentFlowGraph);

    // build graph
    currentBody = body;
    body.block().eval(this);

    // check for reachability
    seenCommands.clear();
    ImmutableList<Command> commands = body.block().commands();
    if (commands.isEmpty()) return;
    dfs(commands.get(0));
    for (Command c : labelsCollector.getAllCommands(body)) {
      if (!seenCommands.contains(c)) 
        Err.warning("" + c.loc() + ": Command is unreachable." + rep(c));
    }
  }

  @Override public void see(Block block) {
    ImmutableList<Command> commands = block.commands();
    for (int i = 1; i < commands.size(); ++i) {
      nextCommand.addFirst(commands.get(i));
      commands.get(i-1).eval(this);
      nextCommand.removeFirst();
    }
    // At this point nextCommand.pollLast() is set by the outer block.
    if (!commands.isEmpty())
      commands.get(commands.size() - 1).eval(this);
  }

  private String rep(Command c) {
    if (c.labels().isEmpty()) return "";
    StringBuilder sb = new StringBuilder();
    sb.append("(");
    for (int i = 0; i < c.labels().size(); ++i) {
      if (i != 0) sb.append(", ");
      sb.append(c.labels().get(i));
    }
    sb.append(")");
    return sb.toString();
  }
  // END top-level methods }}}

  // BEGIN visit nonbranching commands {{{
  private void processNonbranchingCommand(Command command) {
    currentFlowGraph.node(command);
    Command next = nextCommand.peekLast();
    if (next != null) currentFlowGraph.edge(command, next);
  }

  @Override public void see(AssertAssumeCmd assertAssumeCmd) {
    processNonbranchingCommand(assertAssumeCmd);
  }

  @Override public void see(AssignmentCmd assignmentCmd) {
    processNonbranchingCommand(assignmentCmd);
  }

  @Override public void see(CallCmd callCmd) {
    processNonbranchingCommand(callCmd);
  }

  @Override public void see(HavocCmd havocCmd) {
    processNonbranchingCommand(havocCmd);
  }
  // END visit nonbranching commands }}}

  // BEGIN visit branching commands {{{
  @Override public void see(IfCmd ifCmd) {
    currentFlowGraph.node(ifCmd);
    if (ifCmd.no() != null && !ifCmd.no().commands().isEmpty())
      currentFlowGraph.edge(ifCmd, ifCmd.no().commands().get(0));
    else {
      Command next = nextCommand.peekLast();
      if (next != null) currentFlowGraph.edge(ifCmd, next);
    }
    ifCmd.yes().eval(this);
    if (ifCmd.no() != null) ifCmd.no().eval(this);
  }

  @Override public void see(WhileCmd whileCmd) {
    currentFlowGraph.node(whileCmd);
    Command next = nextCommand.peekLast();
    if (next != null) currentFlowGraph.edge(whileCmd, next);
    ImmutableList<Command> commands = whileCmd.body().commands();
    if (!commands.isEmpty()) {
      currentFlowGraph.edge(whileCmd, commands.get(0));
      currentFlowGraph.edge(commands.get(commands.size() - 1), whileCmd);
    }
    whileCmd.body().eval(this);
  }

  @Override public void see(BreakCmd breakCmd) {
    assert false : "todo";
  }

  @Override public void see(GotoCmd gotoCmd) {
    currentFlowGraph.node(gotoCmd);
    for (String s : gotoCmd.successors()) {
      Command next = labelsCollector.getCommand(currentBody, s);
      if (next == null)
        errors.add(new FbError(FbError.Type.MISSING_BLOCK, gotoCmd, s));
      else
        currentFlowGraph.edge(gotoCmd, next);
    }
  }
  // END visit branching commands }}}
 
}
