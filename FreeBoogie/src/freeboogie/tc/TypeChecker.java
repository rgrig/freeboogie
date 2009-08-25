package freeboogie.tc;

import java.math.BigInteger;
import java.util.*;
import java.util.logging.Logger;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;
import com.google.common.collect.UnmodifiableIterator;
import genericutils.*;

import freeboogie.ErrorsFoundException;
import freeboogie.ast.*;
import freeboogie.astutil.TreeChecker;

/**
 * Typechecks an AST.
 *
 * In 'old mode' it uses {@code ForgivingStb} for building a
 * symbol table. 
 * 
 * It also acts more-or-less as a Facade for the whole package.
 *
 * NOTE subtyping is necessary only because of the special type
 * "any" which is likely to be ditched in the future.
 *
 * The typechecking works as follows. The eval functions associate
 * types to nodes in the AST that represent expressions. The check
 * functions ensure that type a can be used when type b is expected,
 * typically by checking the subtype relation. Comparing types
 * is done structurally. The strip function, called repetedly,
 * makes sure that `where' clauses are ignored.
 *
 * Type checking assumes that previous stages such as name resolution
 * (i.e., building of the symbo table) were successful.
 *
 * @author rgrig 
 * @see freeboogie.tc.ForgivingStb
 * @see freeboogie.tc.ForgivingTc
 */
@SuppressWarnings("unused") // many unused parameters
public class TypeChecker extends Evaluator<Type> implements TcInterface {

  private static final Logger log = Logger.getLogger("freeboogie.tc");
  
  // used for primitive types (so reference equality is used below)
  private PrimitiveType boolType, intType, refType;
  
  // used to signal an error in a subexpression and to limit
  // errors caused by other errors
  private PrimitiveType errType;
  
  private SymbolTable st;
  
  private GlobalsCollector gc;
  
  private FlowGraphMaker flowGraphs;
  
  // detected errors
  private List<FbError> errors;
  
  // maps expressions to their types (caches the results of the
  // typechecker)
  private HashMap<Expr, Type> typeOf;
  
  // maps implementations to procedures
  private UsageToDefMap<Implementation, Procedure> implProc;
  
  // maps implementation params to procedure params
  private UsageToDefMap<VariableDecl, VariableDecl> paramMap;

  // maps type variables to their binding types
  private StackedHashMap<Identifier, Type> typeVar;

  // used for (randomized) union-find
  private static final Random rand = new Random(123);

  // implicitSpec.get(x) contains the mappings of type variables
  // to types that were inferred (and used) while type-checking x
  private Map<Ast, Map<Identifier, Type>> implicitSpec;

  // used as a stack of sets; this must be updated whenever
  // we decend into something parametrized by a generic type
  // that can contain expressions (e.g., functions, axioms,
  // procedure, implementation)
  private StackedHashMap<Identifier, Identifier> enclosingTypeVar;

  // accept deprecated constructs
  private boolean acceptOld;

  // records the last processed AST
  private Program ast;

  private int tvLevel; // DBG
  
  // === public interface ===
  
  /**
   * Make the typechecker accept deprecated constructs.
   */
  public void setAcceptOld(boolean acceptOld) {
    this.acceptOld = acceptOld;
  }

  @Override public Program ast() { return ast; }

  /** 
   * Returns implicit specializations deduced/used by the typechecker
   * at various points in the AST. If later you want to check the
   * specialization performed for an ID then you should find the
   * mappings of type variables stored for ALL parents of the ID.
   */
  public Map<Ast, Map<Identifier, Type>> implicitSpec() {
    return implicitSpec;
  }
  
  @Override
  public List<FbError> process(Program ast) {
    assert new TreeChecker().isTree(ast) : "AST is a dag instead of a tree";

    tvLevel = 0; // DBG
    boolType = PrimitiveType.mk(PrimitiveType.Ptype.BOOL, -1);
    intType = PrimitiveType.mk(PrimitiveType.Ptype.INT, -1);
    errType = PrimitiveType.mk(PrimitiveType.Ptype.ERROR, -1);
    
    typeOf = new HashMap<Expr, Type>();
    typeVar = new StackedHashMap<Identifier, Type>();
    implicitSpec = new HashMap<Ast, Map<Identifier, Type>>();
    enclosingTypeVar = new StackedHashMap<Identifier, Identifier>();
    
    // build symbol table
    StbInterface stb = new SymbolTableBuilder();
    errors = stb.process(ast);
    if (!errors.isEmpty()) return errors;
    ast = stb.ast();
    st = stb.st();
    gc = stb.gc();
    
    // check implementations
    ImplementationChecker ic = new ImplementationChecker();
    errors.addAll(ic.process(ast, gc));
    if (!errors.isEmpty()) return errors;
    implProc = ic.implProc();
    paramMap = ic.paramMap();
    
    // check blocks
    flowGraphs = new FlowGraphMaker();
    errors.addAll(flowGraphs.process(ast));
    if (!errors.isEmpty()) return errors;

    // do the typecheck
    ast.eval(this);
    this.ast = ast;
    return errors;
  }

  @Override
  public SimpleGraph<Command> flowGraph(Body body) {
    return flowGraphs.flowGraph(body);
  }
  
  @Override
  public Map<Expr, Type> types() {
    return typeOf;
  }
  
  @Override
  public UsageToDefMap<Implementation, Procedure> implProc() {
    return implProc;
  }
  
  @Override
  public UsageToDefMap<VariableDecl, VariableDecl> paramMap() {
    return paramMap;
  }
  
  @Override
  public SymbolTable st() {
    return st;
  }
  
  // === helper methods ===
  
  // ast may be used for debugging; it's here for symmetry
  private void typeVarEnter(Ast ast) { typeVar.push(); ++tvLevel; }
 
  private void typeVarExit(Ast ast) {
    Map<Identifier, Type> lis = Maps.newHashMap();
    implicitSpec.put(ast, lis);
    for (Map.Entry<Identifier, Type> e : typeVar.peek().entrySet())
      if (!isTypeVar(e.getValue())) lis.put(e.getKey(), e.getValue());
    typeVar.pop();
    --tvLevel;
  }
  
  // gives a TupleType with the types in that list
  private TupleType typeListOfDecl(ImmutableList<VariableDecl> l) {
    ImmutableList.Builder<Type> builder = ImmutableList.builder();
    for (VariableDecl vd : l) builder.add(vd.type());
    return TupleType.mk(builder.build());
  }

  // Computes a TupleType for a list of expressions
  private TupleType typeListOfExpr(ImmutableList<? extends Expr> es) {
    ImmutableList.Builder<Type> builder = ImmutableList.builder();
    for (Expr e : es) builder.add(e.eval(this));
    return TupleType.mk(builder.build());
  }
 
  // replaces all occurrences of UserType(a) with UserType(b) 
  private Type subst(Type t, String a, String b) {
    if (t instanceof UserType) {
      UserType tt = (UserType)t;
      if (tt.name().equals(a)) return UserType.mk(b, null, tt.loc());
      return t;
    } else if (t instanceof MapType) {
      MapType tt = (MapType)t;
      return MapType.mk(
        subst(tt.idxTypes(), a, b),
        subst(tt.elemType(), a, b),
        tt.loc());
    } else if (t instanceof TupleType) {
      TupleType tt = (TupleType) t;
      return TupleType.mk(subst(tt.types(), a, b), tt.loc());
    }
    assert t == null || t instanceof PrimitiveType;
    return t;
  }

  private ImmutableList<Type> subst(
      ImmutableList<Type> ts, 
      String a, 
      String b
  ) {
    ImmutableList.Builder<Type> builder = ImmutableList.builder();
    for (Type t : ts) builder.add(subst(t, a, b));
    return builder.build();
  }
  
  private boolean sub(PrimitiveType a, PrimitiveType b) {
    return a.ptype() == b.ptype();
  }
  
  private boolean sub(MapType a, MapType b) {
    if (!sub(b.idxTypes(), a.idxTypes())) return false;  // contravariant
    return sub(a.elemType(), b.elemType()); // covariant
  }
  
  private boolean sub(UserType a, UserType b) {
    return a.name().equals(b.name());
  }
  
  private boolean sub(ImmutableList<Type> a, ImmutableList<Type> b) {
    if (a.size() != b.size()) return false;
    UnmodifiableIterator<Type> ia = a.iterator();
    UnmodifiableIterator<Type> ib = b.iterator();
    while (ia.hasNext()) if (!sub(ia.next(), ib.next())) return false;
    return true;
  }

  private boolean sub(TupleType a, TupleType b) {
    return sub(a.types(), b.types());
  }
  
  // returns (a <: b)
  private boolean sub(Type a, Type b) {
    if (a == b) return true; // the common case
    if (a == errType || b == errType) return true; // don't trickle up errors

    // (t) == t
    a = stripTuple(a);
    b = stripTuple(b);
    
    // handle type variables
    a = realType(a);
    b = realType(b);
    if (isTypeVar(a) || isTypeVar(b)) {
      equalTypeVar(a, b);
      return true;
    }

    // the main check
    if (a instanceof PrimitiveType && b instanceof PrimitiveType)
      return sub((PrimitiveType)a, (PrimitiveType)b);
    else if (a instanceof MapType && b instanceof MapType)
      return sub((MapType)a, (MapType)b);
    else if (a instanceof UserType && b instanceof UserType) 
      return sub((UserType)a, (UserType)b);
    else if (a instanceof TupleType && b instanceof TupleType)
      return sub((TupleType) a, (TupleType) b);
    else
      return false;
  }

  private Type stripTuple(Type t) {
    if (!(t instanceof TupleType)) return t;
    TupleType tt = (TupleType) t;
    if (tt.types().size() != 1) return t;
    return tt.types().get(0);
  }

  private void collectEnclosingTypeVars(ImmutableList<Identifier> ids) {
    for (Identifier i : ids) enclosingTypeVar.put(i, i);
  }

  private Type realType(Type t) {
    Identifier ai;
    Type nt;
    while (true) {
      ai = getTypeVarDecl(t);
      if (ai == null || (nt = typeVar.get(ai)) == null) break;
      typeVar.put(ai, nt);
      t = nt;
    }
    return t;
  }

  /* Substitutes real types for (known) type variables.
   * If the result is a type variable then an error is reported
   * at location {@code loc}.
   */
  private Type checkRealType(Type t, Ast l) {
    t = substRealType(t);
    if (isTypeVar(t)) {
      errors.add(new FbError(FbError.Type.REQ_SPECIALIZATION, l,
            TypeUtils.typeToString(t), t.loc(), getTypeVarDecl(t)));
      t = errType;
    }
    return t;
  }

  private ImmutableList<Type> checkRealType(ImmutableList<Type> ts, Ast l) {
    ImmutableList.Builder<Type> builder = ImmutableList.builder();
    for (Type t : ts) builder.add(checkRealType(t, t));
    return builder.build();
  }

  /* Changes all occurring type variables in {@code t} into
   * the corresponding real types.  */
  private Type substRealType(Type t) {
    if (t == null) return null;
    if (t instanceof TupleType) {
      TupleType tt = (TupleType) t;
      return TupleType.mk(substRealType(tt.types()), t.loc());
    } if (t instanceof MapType) {
      MapType at = (MapType)t;
      return MapType.mk(
          substRealType(at.idxTypes()),
          substRealType(at.elemType()));
    }
    Type nt = realType(t);
    return nt;
  }

  private ImmutableList<Type> substRealType(ImmutableList<Type> ts) {
    ImmutableList.Builder<Type> builder = ImmutableList.builder();
    for (Type t : ts) builder.add(substRealType(t));
    return builder.build();
  }

  private boolean isTypeVar(Type t) {
    Identifier ai = getTypeVarDecl(t);
    return ai != null && enclosingTypeVar.get(ai) == null;
  }

  private Identifier getTypeVarDecl(Type t) {
    if (!(t instanceof UserType)) return null;
    return st.typeVars.def((UserType)t);
  }

  // pre: |a| and |b| are as 'real' as possible
  private void equalTypeVar(Type a, Type b) {
    assert !isTypeVar(a) || !typeVar.containsKey(getTypeVarDecl(a));
    assert !isTypeVar(b) || !typeVar.containsKey(getTypeVarDecl(b));
    if (!isTypeVar(a) && !isTypeVar(b)) {
      assert TypeUtils.eq(a, b);
      return;
    }
    if (!isTypeVar(a) || (isTypeVar(b)  && rand.nextBoolean())) {
      Type t = a; a = b; b = t;
    }
    Identifier ai = getTypeVarDecl(a);
    if (getTypeVarDecl(b) != ai) {
      log.fine("TC: typevar " + ai.id() + "@" + ai.loc() +
        " == type " + TypeUtils.typeToString(b));
      assert tvLevel > 0; // you probably need to add typeVarEnter/Exit in some places
      typeVar.put(ai, b);
    }
  }

  private void mapExplicitGenerics(
      ImmutableList<Identifier> tvl, 
      ImmutableList<Type> tl
  ) {
    if (tvl.size() < tl.size()) {
      errors.add(new FbError(FbError.Type.GEN_TOOMANY, tl.get(tvl.size())));
      return;
    }
    assert tvLevel > 0;
    UnmodifiableIterator<Identifier> itv = tvl.iterator();
    UnmodifiableIterator<Type> it = tl.iterator();
    while (it.hasNext()) typeVar.put(itv.next(), it.next());
  }
  
  /**
   * If {@code a} cannot be used where {@code b} is expected then an error
   * at location {@code l} is produced and {@code errors} is set.
   */
  private void check(Type a, Type b, Ast l) {
    if (sub(a, b)) return;
    errors.add(new FbError(FbError.Type.NOT_SUBTYPE, l,
          TypeUtils.typeToString(a), TypeUtils.typeToString(b)));
  }
  
  /**
   * Same as {@code check}, except it is more picky about the types:
   * They must be exactly the same.
   */
  private void checkExact(Type a, Type b, Ast l) {
    // BUG? Should || be &&?
    if (sub(a, b) || sub(b, a)) return;
    errors.add(new FbError(FbError.Type.BAD_TYPE, l,
          TypeUtils.typeToString(a), TypeUtils.typeToString(b)));
  }

  // === visiting operators ===
  @Override public PrimitiveType eval(UnaryOp unaryOp) {
    Expr expr = unaryOp.expr();
    Type t = expr.eval(this);
    switch (unaryOp.op()) {
    case MINUS:
      check(t, intType, expr);
      typeOf.put(unaryOp, intType);
      return intType;
    case NOT:
      check(t, boolType, expr);
      typeOf.put(unaryOp, boolType);
      return boolType;
    default:
      assert false;
      return null; // dumb compiler
    }
  }

  @Override public PrimitiveType eval(BinaryOp binaryOp) {
    Expr left = binaryOp.left();
    Expr right = binaryOp.right();
    Type l = left.eval(this);
    Type r = right.eval(this);
    switch (binaryOp.op()) {
    case PLUS:
    case MINUS:
    case MUL:
    case DIV:
    case MOD:
      // integer arguments and integer result
      check(l, intType, left);
      check(r, intType, right);
      typeOf.put(binaryOp, intType);
      return intType;
    case LT:
    case LE:
    case GE:
    case GT:
      // integer arguments and boolean result
      check(l, intType, left);
      check(r, intType, right);
      typeOf.put(binaryOp, boolType);
      return boolType;
    case EQUIV:
    case IMPLIES:
    case AND:
    case OR:
      // boolean arguments and boolean result
      check(l, boolType, left);
      check(r, boolType, right);
      typeOf.put(binaryOp, boolType);
      return boolType;
    case SUBTYPE:
      // l subtype of r and boolean result (TODO: a user type is a subtype of a user type)
      check(l, r, left);
      typeOf.put(binaryOp, boolType);
      return boolType;
    case EQ:
    case NEQ:
      // typeOf(l) == typeOf(r) and boolean result
      typeVarEnter(binaryOp);
      checkExact(l, r, binaryOp);
      typeVarExit(binaryOp);
      typeOf.put(binaryOp, boolType);
      return boolType;
    default:
      assert false;
      return errType; // dumb compiler
    }
  }
  
  // === visiting atoms ===
  @Override public Type eval(Identifier atomId) {
    IdDecl d = st.ids.def(atomId);
    Type t = errType;
    if (d instanceof VariableDecl) {
      VariableDecl vd = (VariableDecl)d;
      typeVarEnter(atomId);
      mapExplicitGenerics(vd.typeArgs(), atomId.types());
      t = checkRealType(vd.type(), atomId);
      typeVarExit(atomId);
    } else if (d instanceof ConstDecl) {
      t = ((ConstDecl)d).type();
    } else assert false;
    typeOf.put(atomId, t);
    return t;
  }

  @Override public PrimitiveType eval(NumberLiteral atomNum) {
    typeOf.put(atomNum, intType);
    return intType;
  }

  @Override public PrimitiveType eval(BooleanLiteral atomLit) {
    switch (atomLit.val()) {
    case TRUE:
    case FALSE:
      typeOf.put(atomLit, boolType);
      return boolType;
    default:
      assert false;
      return errType; // dumb compiler 
    }
  }

  @Override public Type eval(OldExpr atomOld) {
    Type t = atomOld.expr().eval(this);
    typeOf.put(atomOld, t);
    return t;
  }

  @Override public PrimitiveType eval(Quantifier atomQuant) {
    Expr e = atomQuant.expression();
    Type t = atomQuant.expression().eval(this);
    check(t, boolType, e);
    typeOf.put(atomQuant, boolType);
    return boolType;
  }

  @Override public Type eval(FunctionApp atomFun) {
    FunctionDecl d = st.funcs.def(atomFun);
    Signature sig = d.sig();
    ImmutableList<VariableDecl> fargs = sig.args();
    
    typeVarEnter(atomFun);
    mapExplicitGenerics(sig.typeArgs(), atomFun.types());
    Type at = typeListOfExpr(atomFun.args());
    Type fat = typeListOfDecl(fargs);
   
    check(at, fat, atomFun);
    Type rt = checkRealType(typeListOfDecl(sig.results()), atomFun);
    typeVarExit(atomFun);
    typeOf.put(atomFun, rt);
    return rt;
  }

  @Override public Type eval(MapSelect atomMapSelect) {
    Expr atom = atomMapSelect.map();
    Type t = atom.eval(this);
    if (t == errType) return errType;
    if (!(t instanceof MapType)) {
      errors.add(new FbError(FbError.Type.NEED_ARRAY, atom));
      return errType;
    }
    MapType at = (MapType)t;

    // look at indexing types
    ImmutableList<Expr> index = atomMapSelect.idx();
    typeVarEnter(atomMapSelect);
    check(typeListOfExpr(index), TupleType.mk(at.idxTypes()), atomMapSelect);
    Type et = checkRealType(at.elemType(), atomMapSelect);
    typeVarExit(atomMapSelect);
    typeOf.put(atomMapSelect, et);
    return et;
  }
  
  @Override public Type eval(MapUpdate atomMapUpdate) {
    typeVarEnter(atomMapUpdate);
    Expr atom = atomMapUpdate.map();
    ImmutableList<Expr> index = atomMapUpdate.idx();
    Expr val = atomMapUpdate.val();
    Type t = atom.eval(this);
    Type ti = typeListOfExpr(index);
    Type tv = val.eval(this);
    if (
        TypeUtils.eq(t, errType) || 
        TypeUtils.eq(ti, errType) || 
        TypeUtils.eq(tv, errType)) return errType;
    MapType mt;
    if (!(t instanceof MapType)) {
      errors.add(new FbError(FbError.Type.NEED_ARRAY, atom));
      typeVarExit(atomMapUpdate);
      return errType;
    }
    mt = (MapType)t;
    check(typeListOfExpr(index), TupleType.mk(mt.idxTypes()), atomMapUpdate);
    check(tv, mt.elemType(), val);
    typeVarExit(atomMapUpdate);
    typeOf.put(atomMapUpdate, mt);
    return mt;
  }

  // === visit commands ===
  @Override public Type eval(AssignmentCmd assignmentCmd) {
    typeVarEnter(assignmentCmd);
    AstUtils.evalListOfOneAssignment(assignmentCmd.assignments(), this);
    typeVarExit(assignmentCmd);
    return null;
  }

  @Override public Type eval(OneAssignment oneAssignment) {
    Type lt = oneAssignment.lhs().eval(this);
    Type rt = oneAssignment.rhs().eval(this);
    check(rt, lt, oneAssignment);
    return null;
  }

  @Override public Type eval(AssertAssumeCmd assertAssumeCmd) {
    Type t = assertAssumeCmd.expr().eval(this);
    check(t, boolType, assertAssumeCmd);
    return null;
  }

  @Override public Type eval(CallCmd callCmd) {
    Procedure p = st.procs.def(callCmd);
    Signature sig = p.sig();
    ImmutableList<VariableDecl> fargs = sig.args();

    typeVarEnter(callCmd);
    
    // check the actual arguments against the formal ones
    Type at = typeListOfExpr(callCmd.args());
    Type fat = typeListOfDecl(fargs);
    check(at, fat, callCmd);
    
    // check the assignment of the results
    Type lt = typeListOfExpr(callCmd.results());
    Type rt = typeListOfDecl(sig.results());
    check(rt, lt, callCmd);

    typeVarExit(callCmd);
    
    return null;
  }
  
  // === visit various things that must have boolean params ===
  private Type checkBool(ImmutableList<Identifier> tv, Expr e) {
    enclosingTypeVar.push();
    collectEnclosingTypeVars(tv);
    check(e.eval(this), boolType, e);
    enclosingTypeVar.pop();
    return null;
  }

  @Override public Type eval(PostSpec postSpec) {
    return checkBool(postSpec.typeArgs(), postSpec.expr());
  }

  @Override public Type eval(PreSpec preSpec) {
    return checkBool(preSpec.typeArgs(), preSpec.expr());
  }

  @Override public Type eval(Axiom axiom) {
    return checkBool(axiom.typeArgs(), axiom.expr());
  }

  // === keep track of formal generics (see also eval(Axiom...) and eval(AssertAssumeCmd...)) ===
  @Override public Type eval(FunctionDecl function) {
    return null;
  }

  @Override public Type eval(VariableDecl variableDecl) {
    // TODO(radugrigore): check that the 'where' part is a boolean
    return null;
  }

  @Override public Type eval(Procedure procedure) {
    enclosingTypeVar.push();
    collectEnclosingTypeVars(procedure.sig().typeArgs());
    AstUtils.evalListOfPreSpec(procedure.preconditions(), this);
    AstUtils.evalListOfPostSpec(procedure.postconditions(), this);
    AstUtils.evalListOfModifiesSpec(procedure.modifies(), this);
    enclosingTypeVar.pop();
    return null;
  }

  @Override public Type eval(Implementation implementation) {
    enclosingTypeVar.push();
    collectEnclosingTypeVars(implementation.sig().typeArgs());
    implementation.body().eval(this);
    enclosingTypeVar.pop();
    return null;
  }
}
