package freeboogie.tc;

import java.util.logging.Logger;
import java.util.*;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

import freeboogie.ast.*;

// DBG import java.io.PrintWriter;
// DBG import freeboogie.astutil.PrettyPrinter;

/**
 * Builds a symbol table for a given AST, perhaps modifying
 * the AST slightly so that name resolution errors are
 * eliminated.
 *
 * The only modification that this class does at this time
 * is to introduce generics (type variables) on the innermost
 * declaration that contains a (type-) name error. For example,
 * the variable declaration {@code var h : [ref,&lt;x&gt;name]x}
 * is transformed into {@code var h&lt;x&gt; : [ref,&lt;x&gt;name]x}.
 *
 * @author rgrig
 */
public class ForgivingStb extends Transformer implements StbInterface {

  private static final Logger log = Logger.getLogger("freeboogie.tc"); 

  // lists types of errors that MAY be fixed by this class
  private static final EnumSet<FbError.Type> fixable =
    EnumSet.of(FbError.Type.UNDECL_ID);
  
  // does the real work
  private StbInterface stb = new SymbolTableBuilder();

  private Set<UserType> undeclIds;

  // used to collect the local undeclared ids; usde as a stack
  private Deque<Set<String>> toIntroduce;

  @Override public GlobalsCollector gc() { return stb.gc(); }
  @Override public SymbolTable st() { return stb.st(); }
  @Override public Program ast() { return stb.ast(); }

  @Override
  public List<FbError> process(Program ast) {
    boolean unfixable;
    int oldErrCnt = Integer.MAX_VALUE;
    List<FbError> errors, filteredErrors = Lists.newArrayList();
    while (true) {
      errors = stb.process(ast);

      unfixable = false;
      filteredErrors.clear();
      for (FbError e : errors) {
        if (fixable.contains(e.type()))
          filteredErrors.add(e);
        else
          unfixable = true;
      }

      int errCnt = filteredErrors.size();
      if (unfixable || errCnt == 0 || errCnt >= oldErrCnt) break;
      oldErrCnt = errCnt;
      ast = fix(ast, filteredErrors);
      log.info("Running SymbolTableBuilder again.");
    }
    return errors;
  }

  /*
   * This relies on FbError UNDECL_ID to point to AtomId as
   * the location of the error.
   */
  private Program fix(Program ast, List<FbError> errors) {
    undeclIds = Sets.newHashSet();
    for (FbError e : errors) {
      switch (e.type()) {
      case UNDECL_ID:
        Ast l = e.place();
        if (l instanceof UserType) undeclIds.add((UserType)l);
        break;
      default:
        /* do nothing */
      }
    }
    toIntroduce = new ArrayDeque<Set<String>>();
    ast = (Program) ast.eval(this);

    /* DBG 
    System.out.println("=== RESULT OF INTRODUCING GENERICS ===");
    PrintWriter pw = new PrintWriter(System.out);
    PrettyPrinter pp = new PrettyPrinter(pw);
    ast.eval(pp);
    pw.flush();
    */

    return ast;
  }

  // === identify problematic places ===
  @Override
  public void see(
      UserType userType,
      String name, 
      ImmutableList<Type> typeArgs
  ) {
    if (!undeclIds.contains(userType)) return;
    assert name != null;
    if (!toIntroduce.isEmpty()) {
      log.finer("record undecl usertype " + name);
      toIntroduce.getFirst().add(name);
    } else log.fine("can't fix undecl usertype " + name);
  }
  
  // === do corrections, if needed ===
  @Override
  public VariableDecl eval(
      VariableDecl variableDecl,
      ImmutableList<Attribute> attr,
      String name,
      Type type,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    toIntroduce.addFirst(new HashSet<String>());
    type = (Type) type.eval(this);
    typeArgs = introduceGenerics(typeArgs, "var", variableDecl.loc());
    return VariableDecl.mk(
        ImmutableList.<Attribute>of(), 
        name, 
        type, 
        typeArgs, 
        expr,
        variableDecl.loc());
  }

  @Override
  public Axiom eval(
    Axiom axiom,
    ImmutableList<Attribute> attr,
    String name,
    ImmutableList<AtomId> typeArgs,
    Expr expr
  ) {
    toIntroduce.addFirst(new HashSet<String>());
    expr = (Expr)expr.eval(this);
    typeArgs = introduceGenerics(typeArgs, "axiom", axiom.loc());
    return Axiom.mk(
        ImmutableList.<Attribute>of(), 
        name, 
        typeArgs, 
        expr, 
        axiom.loc());
  }

  @Override
  public Signature eval(
      Signature signature,
      String name,
      ImmutableList<AtomId> typeArgs,
      ImmutableList<VariableDecl> args,
      ImmutableList<VariableDecl> results
  ) {
    toIntroduce.addFirst(new HashSet<String>());
    args = AstUtils.evalListOfVariableDecl(args, this);
    results = AstUtils.evalListOfVariableDecl(results, this);
    typeArgs = introduceGenerics(typeArgs, "sig", signature.loc());
    return Signature.mk(name, typeArgs, args, results, signature.loc());
  }

  // TODO(rgrig): I don't like the duplication here. Perhaps
  // PreSpec and PostSpec should be *one* class with an enum,
  // after all?
  @Override public PostSpec eval(
      PostSpec postSpec, 
      boolean free,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    toIntroduce.addFirst(new HashSet<String>());
    expr = (Expr) expr.eval(this);
    typeArgs = introduceGenerics(typeArgs, "post", postSpec.loc());
    return PostSpec.mk(free, typeArgs, expr, postSpec.loc());
  }

  @Override public PreSpec eval(
      PreSpec preSpec, 
      boolean free,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    toIntroduce.addFirst(new HashSet<String>());
    expr = (Expr) expr.eval(this);
    typeArgs = introduceGenerics(typeArgs, "pre", preSpec.loc());
    return PreSpec.mk(free, typeArgs, expr, preSpec.loc());
  }

  @Override
  public AssertAssumeCmd eval(
      AssertAssumeCmd assertAssumeCmd,
      ImmutableList<String> labels,
      AssertAssumeCmd.CmdType type,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    toIntroduce.addFirst(new HashSet<String>());
    expr = (Expr) expr.eval(this);
    typeArgs = introduceGenerics(
        typeArgs, 
        "assert/assume", 
        assertAssumeCmd.loc());
    return AssertAssumeCmd.mk(
        labels, 
        type, 
        typeArgs, 
        expr, 
        assertAssumeCmd.loc());
  }

  private ImmutableList<AtomId> introduceGenerics(
      ImmutableList<AtomId> tv,
      String m,
      FileLocation loc
  ) {
    Set<String> tis = toIntroduce.removeFirst();
    if (tis.isEmpty()) return tv;
    ImmutableList.Builder<AtomId> builder = ImmutableList.builder();
    builder.addAll(tv);
    for (String ti : tis) {
      builder.add(AtomId.mk(ti, null));
      log.fine("Introducing " + ti + " as a generic on " + m + " at " + loc);
    }
    return builder.build();
  }

}

