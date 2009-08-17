package freeboogie.dumpers;

import java.io.*;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
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
      SimpleGraph<Block> fg = tc.flowGraph(impl);
      w.println("digraph \"" + name + "\" {");
      if (!body.blocks().isEmpty())
        w.println("  \"" + body.blocks().get(0).name() + "\" [style=bold];");
      for (Block b : fg.nodesInTopologicalOrder()) {
        w.print("  \"" + b.name() + "\" ");
        if (b.cmd() == null)
          w.print("[shape=circle,label=\"\"]");
        else
          w.print("[shape=box,label=\""+cmdToString(b.cmd())+"\"]");
        w.println(";");
      }
      fg.iterEdge(new Closure<Pair<Block,Block>>() {
        @Override public void go(Pair<Block,Block> t) {
          w.println("  \"" + t.first.name() + "\" -> \"" 
            + t.second.name() + "\";");
        }});
      w.println("}");
      w.flush();
      w.close();
    } catch (FileNotFoundException e) {
      assert false : "PrintWriter should create the file.";
    }
  }
}
