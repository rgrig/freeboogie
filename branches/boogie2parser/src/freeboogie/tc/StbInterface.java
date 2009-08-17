package freeboogie.tc;

import java.util.List;

import freeboogie.ast.Program;

/**
 * A symbol table builder (STB) constructs a symbol table
 * for an AST. It may change the AST to remove errors. The
 * errors that remain are returned.
 *
 * @author rgrig
 */
public interface StbInterface {
  /**
   * Builds a symbol table that can be later retrieved by a
   * call to {@code st()}. The symbol table corresponds to
   * the AST returned by {@code ast()}, which MAY be (slightly)
   * different from {@code p}.
   */
  List<FbError> process(Program p);

  /**
   * Returns the AST to which the symbol table returned by
   * {@code getST()} corresponds.
   */
  Program ast();

  /**
   * Returns the latest built symbol table.
   */
  SymbolTable st();

  /**
   * Returns the globals collector used during building of
   * the symbol table.
   */
  GlobalsCollector gc();
}
