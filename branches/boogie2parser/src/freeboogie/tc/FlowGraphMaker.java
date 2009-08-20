package freeboogie.tc;

import java.util.*;

import com.google.common.collect.*;
import genericutils.Err;
import genericutils.SimpleGraph;

import freeboogie.ast.*;

/**
  Constructs a flowgraph of blocks for each implementation.

  After {@code process(ast)} you can ask {@code flowGraph(body)}
  and {@code flowgraph(implementation)} to get a {@code
  SimpleGraph&lt;Command&gt;}. Processing checks for inexistent
  labels and reports a list of errors. Unreachability warnings
  are printed.

  @author rgrig
 */
@SuppressWarnings("unused") // unused params
public class FlowGraphMaker extends Transformer {
  // We visit commands twice and do different things. Two
  // transformers seems too heavyweight.
  private static enum Phase {
    COLLECT_NAMES,
    CONNECT_COMMANDS
  }
  private Phase phase;

   // finds commands (in the currently processed Body) by label
  private HashMap<String, Command> cmdByLabel;

  // a set of commands in the current body, built during COLLECT_NAMES
  private HashSet<Command> allCommands = Sets.newHashSet();

  // A stack with next commands within each nested block.
  private ArrayDeque<Command> nextCommand = new ArrayDeque<Command>();
  
  // the flow graph currently being built
  private SimpleGraph<Command> currentFlowGraph;
  
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
    errors = Lists.newArrayList();
    flowGraphs = Maps.newHashMap();
    ast.eval(this);
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
  
  // === visiting methods ===
  
  @Override
  public void see(
      Body body, 
      ImmutableList<VariableDecl> vars,
      Block block
  ) {
    // initialize graph
    currentFlowGraph = new SimpleGraph<Command>();
    flowGraphs.put(body, currentFlowGraph);
    allCommands.clear();

    // build graph
    phase = Phase.COLLECT_NAMES;
    block.eval(this);
    phase = Phase.CONNECT_COMMANDS;
    block.eval(this);

    // check for reachability
    seenCommands.clear();
    if (block.commands().isEmpty()) return;
    dfs(block.commands().get(0));
    for (Command c : allCommands) {
      if (!seenCommands.contains(c)) 
        Err.warning("" + c.loc() + ": Command is unreachable." + rep(c));
    }
  }

  @Override
  public void see(Block block, ImmutableList<Command> commands) {
    switch (phase) {
      case COLLECT_NAMES:
        AstUtils.evalListOfCommand(commands, this);
        break;
      case CONNECT_COMMANDS:
        for (int i = 1; i < commands.size(); ++i) {
          nextCommand.addFirst(commands.get(i));
          commands.get(i-1).eval(this);
          nextCommand.removeFirst();
        }
        // At this point nextCommand.pollLast() is set by the outer block.
        if (!commands.isEmpty())
          commands.get(commands.size() - 1).eval(this);
        break;
      default:
        assert false: "There's no such flowgraph construction phase.";
    }
  }
  
  @Override public void see(Command c) {
    switch (phase) {
      case COLLECT_NAMES:
        allCommands.add(c);
        for (String l : c.labels()) cmdByLabel.put(l, c);
        break;
      case CONNECT_COMMANDS:
        Command next = nextCommand.pollLast();
        if (next != null)
          currentFlowGraph.edge(c, next);
        break;
      default:
        assert false: "There's no such flowgraph construction phase.";
    }
  }

  @Override public void see(
      GotoCmd gotoCmd, 
      ImmutableList<String> labels,
      ImmutableList<String> successors
  ) {
    switch (phase) {
      case COLLECT_NAMES:
        see(gotoCmd);
        break;
      case CONNECT_COMMANDS:
        for (String s : successors) {
          Command next = cmdByLabel.get(s);
          if (next == null)
            errors.add(new FbError(FbError.Type.MISSING_BLOCK, gotoCmd, s));
          else
            currentFlowGraph.edge(gotoCmd, next);
        }
        break;
      default:
        assert false: "There's no such flowgraph construction phase.";
    }
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
 }
