package freeboogie.tc;

import java.util.*;

import com.google.common.collect.ImmutableList;
import genericutils.StackedHashMap;

import freeboogie.ast.*;

/**
 * Constructs a {@code SymbolTable} from an AST.
 *
 * TODO(rgrig): Compute map axiom_name <-> axiom
 * 
 * @author rgrig 
 * @author miko
 */
@SuppressWarnings("unused") // lots of unused parameters
public class SymbolTableBuilder extends Transformer implements StbInterface {
  private StackedHashMap<String, VariableDecl> localVarDecl;
  private StackedHashMap<String, AtomId> typeVarDecl;

  private Program p;
  private SymbolTable symbolTable;
  private GlobalsCollector gc;
  
  // problems found while building the symbol table 
  private List<FbError> errors;
  
  // for modifies spec we ignore the arguments
  private boolean lookInLocalScopes;
  
  /**
   * Builds a symbol table. Reports name clashes (because it
   * uses {@code GlobalsCollector}. Reports undeclared variables.
   * @param ast the AST to analyze
   * @return a list with the problems detected
   */
  @Override
  public List<FbError> process(Program p) {
    localVarDecl = new StackedHashMap<String, VariableDecl>();
    typeVarDecl = new StackedHashMap<String, AtomId>();
    symbolTable = new SymbolTable();
    gc = new GlobalsCollector();
    lookInLocalScopes = true;
    errors = gc.process(p);
    this.p = (Program) p.eval(this);
    return errors;
  }

  @Override public Program ast() { return p; }
  @Override public SymbolTable st() { return symbolTable; }
  @Override public GlobalsCollector gc() { return gc; }
  
  // === helpers ===
  
  // reports an error at location l if d is null
  private <T> T check(T d, String s, Ast l) {
    if (d != null) return d;
    errors.add(new FbError(FbError.Type.UNDECL_ID, l, s));
    return null;
  }
  
  private IdDecl lookup(String s, Ast l) {
    IdDecl r = localVarDecl.get(s);
    if (r == null) r = gc.idDef(s);
    return check(r, s, l);
  }

  private void collectTypeVars(
      Map<String, AtomId> tv, 
      ImmutableList<AtomId> ids
  ) {
    for (AtomId ai : ids) {
      if (tv.get(ai.id()) != null)
        errors.add(new FbError(FbError.Type.TV_ALREADY_DEF, ai, ai.id()));
      symbolTable.typeVars.seenDef(ai);
      typeVarDecl.put(ai.id(), ai);
    }
  }
  
  // === visit methods ===
  
  @Override
  public void see(
      UserType userType, 
      String name, 
      ImmutableList<Type> typeArgs
  ) {
    AtomId tv = typeVarDecl.get(name);
    if (tv != null)
      symbolTable.typeVars.put(userType, tv);
    else
      symbolTable.types.put(userType, check(gc.typeDef(name), name, userType));
  }

  @Override
  public void see(
      CallCmd callCmd, 
      ImmutableList<String> labels,
      String p, 
      ImmutableList<Type> types, 
      ImmutableList<AtomId> results, 
      ImmutableList<Expr> args
  ) {
    symbolTable.procs.put(callCmd, check(gc.procDef(p), p, callCmd));
    AstUtils.evalListOfType(types, this);
    AstUtils.evalListOfAtomId(results, this);
    AstUtils.evalListOfExpr(args, this);
  }

  @Override
  public void see(
      AtomFun atomFun, 
      String f, 
      ImmutableList<Type> types, 
      ImmutableList<Expr> args
  ) {
    symbolTable.funcs.put(atomFun, check(gc.funDef(f), f, atomFun));
    AstUtils.evalListOfType(types, this);
    AstUtils.evalListOfExpr(args, this);
  }

  @Override
  public void see(AtomId atomId, String id, ImmutableList<Type> types) {
    symbolTable.ids.put(atomId, lookup(id, atomId));
    AstUtils.evalListOfType(types, this);
  }

  // === collect info from local scopes ===
  @Override
  public void see(
    VariableDecl variableDecl,
    ImmutableList<Attribute> attr,
    String name,
    Type type,
    ImmutableList<AtomId> typeVars
  ) {
    symbolTable.ids.seenDef(variableDecl);
    typeVarDecl.push();
    collectTypeVars(typeVarDecl.peek(), typeVars);
    Map<String, VariableDecl> scope = localVarDecl.peek();
    if (localVarDecl.frames() > 0 && name != null) {
      // we are in a local scope
      VariableDecl old = scope.get(name);
      if (old != null)
        errors.add(new FbError(FbError.Type.ALREADY_DEF, variableDecl, name));
      else 
        scope.put(name, variableDecl);
    }
    type.eval(this);
    typeVarDecl.pop();
  }

  @Override
  public void see(
    ConstDecl constDecl,
    ImmutableList<Attribute> attr,
    String id,
    Type type,
    boolean uniq
  ) {
    symbolTable.ids.seenDef(constDecl);
    type.eval(this);
  }
  
  @Override
  public void see(
    Signature signature,
    String name,
    ImmutableList<AtomId> typeArgs,
    ImmutableList<VariableDecl> args,
    ImmutableList<VariableDecl> results
  ) {
    collectTypeVars(typeVarDecl.peek(), typeArgs);
    AstUtils.evalListOfVariableDecl(args, this);
    AstUtils.evalListOfVariableDecl(results, this);
  }

  
  // === keep track of local scopes ===
  @Override
  public void see(
    Procedure procedure,
    ImmutableList<Attribute> attr,
    Signature sig,
    ImmutableList<PreSpec> pre,
    ImmutableList<PostSpec> post,
    ImmutableList<ModifiesSpec> modifies
  ) {
    symbolTable.procs.seenDef(procedure);
    localVarDecl.push();
    typeVarDecl.push();
    sig.eval(this);
    AstUtils.evalListOfPreSpec(pre, this);
    AstUtils.evalListOfPostSpec(post, this);
    AstUtils.evalListOfModifiesSpec(modifies, this);
    typeVarDecl.pop();
    localVarDecl.pop();
  }

  @Override
  public void see(
    Implementation implementation,
    ImmutableList<Attribute> attr,
    Signature sig,
    Body body
  ) {
    localVarDecl.push();
    typeVarDecl.push();
    sig.eval(this);
    body.eval(this);
    typeVarDecl.pop();
    localVarDecl.pop();
  }

  @Override
  public void see(
    FunctionDecl function,
    ImmutableList<Attribute> attr,
    Signature sig
  ) {
    symbolTable.funcs.seenDef(function);
    typeVarDecl.push();
    sig.eval(this);
    typeVarDecl.pop();
  }
  
  @Override
  public void see(
    AtomQuant atomQuant,
    AtomQuant.QuantType quant,
    ImmutableList<VariableDecl> vars,
    ImmutableList<Attribute> attr,
    Expr e
  ) {
    localVarDecl.push();
    AstUtils.evalListOfVariableDecl(vars, this);
    AstUtils.evalListOfAttribute(attr, this);
    e.eval(this);
    localVarDecl.pop();
  }
  
  @Override
  public void see(
    Axiom axiom,
    ImmutableList<Attribute> attr, 
    String name,
    ImmutableList<AtomId> typeArgs,
    Expr expr
  ) {
    typeVarDecl.push();
    collectTypeVars(typeVarDecl.peek(), typeArgs);
    expr.eval(this);
    typeVarDecl.pop();
  }
  
  @Override
  public void see(
      AssertAssumeCmd assertAssumeCmd, 
      ImmutableList<String> labels,
      AssertAssumeCmd.CmdType type, 
      ImmutableList<AtomId> typeVars, 
      Expr expr
  ) {
    typeVarDecl.push();
    collectTypeVars(typeVarDecl.peek(), typeVars);
    expr.eval(this);
    typeVarDecl.pop();
  }
  
  // === remember if we are below a modifies spec ===
  
  @Override public void see(
      ModifiesSpec modifiesSpec, 
      boolean free,
      ImmutableList<AtomId> ids
  ) {
    assert lookInLocalScopes : "no nesting of modifies";
    lookInLocalScopes = false;
    AstUtils.evalListOfAtomId(ids, this);
    lookInLocalScopes = true;
  }

  @Override public void see(
      PostSpec postSpec, 
      boolean free,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    typeVarDecl.push();
    collectTypeVars(typeVarDecl.peek(), typeArgs);
    expr.eval(this);
    typeVarDecl.pop();
  }

  @Override public void see(
      PreSpec preSpec, 
      boolean free,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    typeVarDecl.push();
    collectTypeVars(typeVarDecl.peek(), typeArgs);
    expr.eval(this);
    typeVarDecl.pop();
  }
}
