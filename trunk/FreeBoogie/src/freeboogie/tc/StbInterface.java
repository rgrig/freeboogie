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
   * Returns the latest built symbol table.
   */
  SymbolTable st();

  /**
   * Returns the globals collector used during building of
   * the symbol table.
   */
  GlobalsCollector gc();
}
