package freeboogie.tc;

import freeboogie.ast.*;

/**
 * A structure whose members connect usages to definitions.
 *
 * @author rgrig 
 */
public class SymbolTable {
  /** User defined types. */
  public UsageToDefMap<UserType, TypeDecl> types
    = new UsageToDefMap<UserType, TypeDecl>();
  
  /** Procedures. */
  public UsageToDefMap<CallCmd, Procedure> procs
    = new UsageToDefMap<CallCmd, Procedure>();
  
  /** Functions. */
  public UsageToDefMap<AtomFun, FunctionDecl> funcs
    = new UsageToDefMap<AtomFun, FunctionDecl>();
  
  /**
   * Identifiers. The declarations might only be {@code ConstDecl} and
   * {@code VariableDecl}.
   */
  public UsageToDefMap<AtomId, GlobalDecl> ids
    = new UsageToDefMap<AtomId, GlobalDecl>();

  /** Type variables. */
  public UsageToDefMap<UserType, AtomId> typeVars
    = new UsageToDefMap<UserType, AtomId>();
}
