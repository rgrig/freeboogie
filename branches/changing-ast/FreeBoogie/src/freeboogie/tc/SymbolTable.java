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
  
  /** Identifiers. */
  public UsageToDefMap<AtomId, IdDecl> ids
    = new UsageToDefMap<AtomId, IdDecl>();

  /** Type variables. */
  public UsageToDefMap<UserType, AtomId> typeVars
    = new UsageToDefMap<UserType, AtomId>();
}
