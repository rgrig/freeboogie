package freeboogie.dumpers;

import java.io.*;
import java.util.HashMap;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;
import genericutils.*;

import freeboogie.ast.*;
import freeboogie.astutil.PrettyPrinter;
import freeboogie.tc.TcInterface;

/**
 * Dumps flow graphs for all implementations in dot format.
 *
 * TODO: Move to freeboogie.astutil and remove this package.
 *
 * @author rgrig 
 */
@SuppressWarnings("unused") // unused parameters
public class FlowGraphDumper extends Transformer {
  private File directory;

  public void directory(File directory) {
    Preconditions.checkArgument(directory.exists());
    this.directory = directory;
  }

  private String cmdToString(Command c) {
    StringWriter sw = new StringWriter();
    PrettyPrinter pp = new PrettyPrinter();
    pp.writer(sw);
    c.eval(pp);
    return sw.toString();
  }

  @Override
  public void see(
    Implementation impl,
    ImmutableList<Attribute> attr,
    Signature sig,
    Body body
  ) {
    String name = 
      impl.sig().name() + 
      "_at_" + 
      impl.loc().toString().replace(':', '-');
    try {
      final PrintWriter w = new PrintWriter(new File(directory, name));
      SimpleGraph<Command> fg = tc.flowGraph(body);
      w.println("digraph \"" + name + "\" {");
      final HashMap<Command, String> blockNames = Maps.newHashMap();
      for (Command c : body.block().commands()) 
        blockNames.put(c, Id.get("L"));
      if (!body.block().commands().isEmpty()) {
        w.println("  \"" + blockNames.get(body.block().commands().get(0)) + 
            "\" [style=bold];");
      }
      for (Command c : body.block().commands()) {
        w.print("  \"" + blockNames.get(c) + "\" ");
        w.print("[shape=box,label=\""+cmdToString(c)+"\"]");
        w.println(";");
      }
      fg.iterEdge(new Closure<Pair<Command,Command>>() {
        @Override public void go(Pair<Command,Command> t) {
          w.println("  \"" + blockNames.get(t.first) + "\" -> \"" 
            + blockNames.get(t.second) + "\";");
        }});
      w.println("}");
      w.flush();
      w.close();
    } catch (FileNotFoundException e) {
      assert false : "PrintWriter should create the file.";
    }
  }
}
