package freeboogie.tc;

import java.util.HashMap;
import java.util.Map;

import freeboogie.ast.*;
import freeboogie.util.Err;
import freeboogie.util.StackedHashMap;

/**
 * Constructs a {@code SymbolTable} from an AST.
 * 
 * @author rgrig 
 * @author miko
 */
@SuppressWarnings("unused") // lots of unused parameters
public class SymbolTableBuilder extends Transformer {
  private StackedHashMap<String, VariableDecl> localVarDecl;
  private StackedHashMap<String, AtomId> typeVarDecl;

  private SymbolTable symbolTable;
  private GlobalsCollector gc;
  
  // where there undeclared identifiers?
  private boolean errors;
  
  // for modifies spec we ignore the arguments
  private boolean lookInLocalScopes;
  
  /**
   * Builds a symbol table. Reports name clashes (because it
   * uses {@code GlobalsCollector}. Reports undeclared variables.
   * @param ast the AST to analyze
   * @return whether there were any problems detected
   */
  public boolean process(Declaration ast) {
    errors = false;
    localVarDecl = new StackedHashMap<String, VariableDecl>();
    typeVarDecl = new StackedHashMap<String, AtomId>();
    symbolTable = new SymbolTable();
    gc = new GlobalsCollector();
    lookInLocalScopes = true;
    boolean e = gc.process(ast);
    ast.eval(this);
    return errors || e;
  }

  /**
   * Returns the symbol table.
   * @return the symbol table
   */
  public SymbolTable getST() {
    return symbolTable;
  }
  
  /**
   * Returns the globals collector, which can be used to resolve global names.
   * @return the globals collector
   */
  public GlobalsCollector getGC() {
    return gc;
  }
  
  // === helpers ===
  
  // reports an error at location l if d s null
  private <T> T check(T d, String s, AstLocation l) {
    if (d != null) return d;
    Err.error("" + l + ": Undeclared identifier " + s + ".");
    errors = true;
    return null;
  }
  
  // the return might by ConstDecl or VariableDecl
  private Declaration lookup(String s, AstLocation l) {
    Declaration r = localVarDecl.get(s);
    if (r == null) r = gc.idDef(s);
    return check(r, s, l);
  }

  private void collectTypeVars(Map<String, AtomId> tv, Identifiers ids) {
    if (ids == null) return;
    AtomId a = ids.getId();
    String n = a.getId();
    if (tv.get(n) != null) {
      Err.error("" + a.loc() + ": Type variable already defined.");
      errors = true;
    }
    symbolTable.typeVars.seenDef(ids.getId());
    typeVarDecl.put(n, a);
    collectTypeVars(tv, ids.getTail());
  }
  
  // === visit methods ===
  
  // Grr, why doesn't Java have functions as parameters or at least macros?
  
  @Override
  public void see(UserType userType, String name) {
    AtomId tv = typeVarDecl.get(name);
    if (tv != null)
      symbolTable.typeVars.put(userType, tv);
    else
      symbolTable.types.put(userType, check(gc.typeDef(name), name, userType.loc()));
  }

  @Override
  public void see(CallCmd callCmd, String p, TupleType types, Identifiers results, Exprs args) {
    symbolTable.procs.put(callCmd, check(gc.procDef(p), p, callCmd.loc()));
    if (types != null) types.eval(this);
    if (results != null) results.eval(this);
    if (args != null) args.eval(this);
  }

  @Override
  public void see(AtomFun atomFun, String f, TupleType types, Exprs args) {
    symbolTable.funcs.put(atomFun, check(gc.funDef(f), f, atomFun.loc()));
    if (types != null) types.eval(this);
    if (args != null) args.eval(this);
  }

  @Override
  public void see(AtomId atomId, String id, TupleType types) {
    symbolTable.ids.put(atomId, lookup(id, atomId.loc()));
    if (types != null) types.eval(this);
  }

  // === collect info from local scopes ===
  @Override
  public void see(VariableDecl variableDecl, String name, Type type, Identifiers typeVars, Declaration tail) {
    symbolTable.ids.seenDef(variableDecl);
    typeVarDecl.push();
    collectTypeVars(typeVarDecl.peek(), typeVars);
    Map<String, VariableDecl> scope = localVarDecl.peek();
    if (scope != null && name != null) {
      // we are in a local scope
      VariableDecl old = scope.get(name);
      if (old != null) {
        Err.error("" + variableDecl.loc() + ": Variable already defined.");
        errors = true;
      } else 
        scope.put(name, variableDecl);
    }
    type.eval(this);
    typeVarDecl.pop();
    if (tail != null) tail.eval(this);
  }

  @Override
  public void see(ConstDecl constDecl, String id, Type type, Declaration tail) {
    symbolTable.ids.seenDef(constDecl);
    type.eval(this);
    if (tail != null) tail.eval(this);
  }
  
  @Override
  public void see(Signature signature, String name, Declaration args, Declaration results, Identifiers typeVars) {
    collectTypeVars(typeVarDecl.peek(), typeVars);
    if (args != null) args.eval(this);
    if (results != null) results.eval(this);
  }

  
  // === keep track of local scopes ===
  @Override
  public void see(Procedure procedure, Signature sig, Specification spec, Declaration tail) {
    symbolTable.procs.seenDef(procedure);
    localVarDecl.push();
    typeVarDecl.push();
    sig.eval(this);
    if (spec != null) spec.eval(this);
    typeVarDecl.pop();
    localVarDecl.pop();
    if (tail != null) tail.eval(this);
  }

  @Override
  public void see(Implementation implementation, Signature sig, Body body, Declaration tail) {
    localVarDecl.push();
    typeVarDecl.push();
    sig.eval(this);
    body.eval(this);
    typeVarDecl.pop();
    localVarDecl.pop();
    if (tail != null) tail.eval(this);
  }

  @Override
  public void see(Function function, Signature sig, Declaration tail) {
    symbolTable.funcs.seenDef(function);
    typeVarDecl.push();
    sig.eval(this);
    typeVarDecl.pop();
    if (tail != null) tail.eval(this);
  }
  
  @Override
  public void see(AtomQuant atomQuant, AtomQuant.QuantType quant, Declaration vars, Trigger trig, Expr e) {
    localVarDecl.push();
    vars.eval(this);
    if (trig != null) trig.eval(this);
    e.eval(this);
    localVarDecl.pop();
  }
  
  // === remember if we are below a modifies spec ===
  
  @Override
  public void see(Specification specification, Specification.SpecType type, Expr expr, boolean free, Specification tail) {
    if (type == Specification.SpecType.MODIFIES) {
      assert lookInLocalScopes; // no nesting
      lookInLocalScopes = false;
    }
    expr.eval(this);
    lookInLocalScopes = true;
    if (tail != null) tail.eval(this);
  }
  
  
  // === do not look at goto-s ===
  @Override
  public void see(Block block, String name, Commands cmds, Identifiers succ, Block tail) {
    if (cmds != null) cmds.eval(this);
    if (tail != null) tail.eval(this);
  }
}
