package freeboogie.tc;

import java.util.*;

import com.google.common.collect.ImmutableList;
import genericutils.StackedHashMap;

import freeboogie.ast.*;

//DBG import java.io.PrintWriter;
//DBG import freeboogie.astutil.PrettyPrinter;

/**
 * Makes sure that all (eligible) IDs have explicit specializations
 * attached. The information used to achieve this consists of
 * (1) errors: a map from expressions to the AtomId in the type
 * variable declaration to which the expresion type evaluated
 * &mdash; this can be easily derived from the errors of type
 * REQ_SPECIALIZATION provided by {@code TypeChecker}, 
 * (2) desired: a map from expressions to their desired types
 * &mdash; this can be provided by {@code Inferrer}, and
 * (3) implicit: the implicit specializations identified
 * by the {@code TypeChecker} &mdash; these need to be 'folded'.
 *
 * A symbol table for the input AST is needed so that declarations
 * of identifiers (which may need specialisation) can be quickly
 * looked up.
 *
 * @see freeboogie.tc.TypeChecker
 * @author rgrig
 */
public class Specializer extends Transformer {

  // used to look up variable, functions, and procedures
  private SymbolTable st;

  // errors.get(x) is the (declaration of) the type variable that
  // corresponds to x; of course, the type should be a type, not
  // a type variable, so that's why these are 'errors'
  private Map<Expr, AtomId> errors;

  // desired types for various nodes
  private Map<Expr, Type> desired;

  // the specializations found by the type-checker
  private Map<Ast, Map<AtomId, Type>> implicit;

  // used to 'collate' specializations found by the typechecker
  private StackedHashMap<AtomId, Type> specialisations;

  // === public interface ===
  
  /**
   * Introduce explicit specialisations in {@code ast}.
   *
   * @param ast the program in which to introduce explicit specializations
   * @param st a symbol table that knows symbols in {@code ast}
   * @param errors maps expressions to type variable declarations
   *            (they are 'errors' because expressions should have
   *            'real' types)
   * @param desired maps expressions to a gues of what their type should be
   *            (NOTE: This might also be a type variable, that should
   *            be introduced as a generic later on)
   * @param implicit contains the type parameters identified by
   *            {@code TypeChecker}
   */
  public Program process(
    Program ast, 
    SymbolTable st,
    Map<Expr, AtomId> errors,
    Map<Expr, Type> desired,
    Map<Ast, Map<AtomId, Type>> implicit
  ) {
    this.st = st;
    this.errors = errors;
    this.desired = desired;
    this.implicit = implicit;
    specialisations = new StackedHashMap<AtomId, Type>();

    for (Expr e : errors.keySet()) assert desired.containsKey(e);

    return (Program) ast.eval(this);
  }

  // === workers ===
  
  @Override
  public void enterNode(Ast n) {
    Map<AtomId, Type> is = implicit.get(n);
    AtomId ai = n instanceof Expr ? errors.get((Expr)n) : null;
    if (is != null || ai != null) {
      // DBG System.out.println("PUSH AT " + n.loc());
      specialisations.push();
    }
    if (is != null) {
      /* DBG
      for (Map.Entry<AtomId, Type> e : is.entrySet())
        System.out.println("add(tc): " + e.getKey().getId() + "->" + TypeUtils.typeToString(e.getValue()));
      */
      specialisations.putAll(is);
    }
    if (ai != null) {
      // DBG System.out.println("add(infer): " + ai.getId() + "->" + TypeUtils.typeToString(desired.get((Expr)n)));
      specialisations.put(ai, desired.get((Expr)n));
    }
  }

  @Override
  public void exitNode(Ast n) {
    if (implicit.containsKey(n) || (n instanceof Expr && errors.containsKey((Expr)n))) {
      // DBG System.out.println("POP AT " + n.loc());
      specialisations.pop();
    }
  }

  @Override
  public AtomId eval(AtomId atomId, String id, ImmutableList<Type> types) {
    Declaration d = st.ids.def(atomId);
    if (!(d instanceof VariableDecl)) return atomId;
    VariableDecl vd = (VariableDecl)d;
    types = prepareTypeList(vd.typeArgs());
    if (types == null) return atomId;
    return AtomId.mk(id, types, atomId.loc());
  }

  @Override
  public AtomFun eval(
      AtomFun atomFun, 
      String function, 
      ImmutableList<Type> types, 
      ImmutableList<Expr> args
  ) {
    args = AstUtils.evalListOfExpr(args, this);
    Signature sig = st.funcs.def(atomFun).sig();
    types = prepareTypeList(sig.typeArgs());
    return AtomFun.mk(function, types, args, atomFun.loc());
  }

  @Override
  public CallCmd eval(
      CallCmd callCmd,
      ImmutableList<String> labels,
      String procedure, 
      ImmutableList<Type> types, 
      ImmutableList<AtomId> results, 
      ImmutableList<Expr> args
  ) {
    results = AstUtils.evalListOfAtomId(results, this);
    args = AstUtils.evalListOfExpr(args, this);
    Signature sig = st.procs.def(callCmd).sig();
    types = prepareTypeList(sig.typeArgs());
    return CallCmd.mk(labels, procedure, types, results, args);
  }

  
  // === helpers ===

  private ImmutableList<Type> prepareTypeList(ImmutableList<AtomId> ids) {
    ImmutableList.Builder<Type> builder = ImmutableList.builder();
    for (AtomId ai : ids) {
      Type t = specialisations.get(ai);
      if (t == null) return null;
      builder.add(t);
    }
    return builder.build();
  }
}
