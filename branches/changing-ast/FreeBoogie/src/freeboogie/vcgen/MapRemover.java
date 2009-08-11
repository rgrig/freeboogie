package freeboogie.vcgen;

import java.util.HashSet;
import java.util.logging.Logger;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Sets;

import freeboogie.ast.*;
import freeboogie.tc.TcInterface;
import freeboogie.tc.TypeUtils;

/**
 * Replaces all map reads and writes by explicit calls to
 * <tt>select</tt> and <tt>update</tt>.
 */
public class MapRemover extends Transformer {
  private static final Logger log = Logger.getLogger("freeboogie.vcgen");
  private HashSet<Integer> arities = Sets.newHashSet();

  // TODO move in eval(Program...)
  @Override
  public Program process(Program p, TcInterface tc) {
    arities.clear();
    p = (Program) p.eval(this);
    if (arities.isEmpty()) return p;

    ImmutableList.Builder<FunctionDecl> functions = ImmutableList.builder();
    ImmutableList.Builder<Axiom> axioms = ImmutableList.builder();
    functions.addAll(p.functions());
    axioms.addAll(p.axioms());

    for (Integer n : arities) {
      // add "function $$selectN<TV, T1, ..., TN>
      //        (map : [T1, ..., TN]TV, x1 : T1, ..., xN : TN)
      //        returns (result : TV);"
      functions.add(mkFunctionDecl("$$select" + n, e(), mkType("TV")));

      // add "function $$updateN<TV, T1, ..., TN>
      //        (val : TV, map : [T1, ..., TN]TV, x1 : T1, ..., xN : TN)
      //        returns (result : [T1, ..., TN]TV);"
      functions.add(mkFunctionDecl(
          "$$update" + n, 
          a(mkVarDecl("val", mkType("TV"))).e(),
          mkMapType(n)));

      // add "axiom<TV, T1, ..., TN>
      //        (forall m : [T1, ..., TN]TV, v : TV, x1 : T1, ..., xN : TN ::
      //          $$selectN($$updateN(v, m, x1, ..., xN), x1, ..., xN) == v
      //        );
      axioms.add(mkAxiom(
          a(mkMapDecl("m", n)).
          a(mkVarDecl("v", mkType("TV"))).
          a(nVarDecl("x", n)).e(),
          mkEq(
              mkFun(
                  "$$select" + n,
                  a(mkFun(
                      "$$update" + n,
                      a(mkId("v")).
                      a(mkId("m")).
                      a(nIds("x", n)).e())).
                  a(nIds("x", n)).e()),
              mkId("v"))));

      for (int i = n; i > 0; --i) {
        // "axiom<TV, T1, ..., TN>
        //    (forall m : [T1, ..., TN] TV, v : TV,
        //      x1 : T1, ..., xN : TN, y1 : T1, ..., yN : TN ::
        //      xi != yi ==>
        //      $$selectN($$updateN(v, m, x1, ..., xN), y1, ..., yN) ==
        //        $$selectN(m, y1, ..., yN));
        axioms.add(mkAxiom(
            a(mkMapDecl("m", n)).
            a(mkVarDecl("v", mkType("TV"))).
            a(nVarDecl("x", n)).
            a(nVarDecl("y", n)).E(),
            mkImplies(
                mkNotEq(mkId("x" + i), mkId("y" + i)),
                mkEq(
                    mkFun(
                        "$$select" + n,
                        a(mkFun(
                            "$$update" + n,
                            a(mkId("v")).
                            a(mkId("m")).
                            a(nIds("x", n)).e())).
                        a(nIds("y", n)).e()),
                    mkFun(
                        "$$select" + n,
                        a(mkId("m")).
                        a(nIds("y", n)).e())))));
      } // for i
    } // for n
    return TypeUtils.internalTypecheck(p, tc);
  }

  @Override
  public AtomFun eval(
      AtomMapSelect atomMapSelect,
      Atom atom,
      ImmutableList<Expr> idx
  ) {
    atom = (Atom) atom.eval(this);
    idx = AstUtils.evalListOfExpr(idx, this);
    int n = idx.size();
    arities.add(n);
    return mkFun("$$select" + n, a(atom).a(idx).e());
  }

  @Override
  public AtomFun eval(
      AtomMapUpdate atomMapUpdate,
      Atom atom,
      ImmutableList<Expr> idx,
      Expr val
  ) {
    atom = (Atom)atom.eval(this);
    idx = AstUtils.evalListOfExpr(idx, this);
    val = (Expr)val.eval(this);
    int n = idx.size();
    arities.add(n);
    return AtomFun.mk("$$update" + n, a(val).a(atom).a(idx).e());
  }

  // === helpers ===

  // Used to concisely build an immutable list by saying
  //   a(element).a(list).a(element).e()
  private static class BuilderWrapper<T> {
    private ImmutableList.Builder<T> b = ImmutableList.builder();

    public static <T> BuilderWrapper<T> n() { 
      return new BuilderWrapper<T>();
    }

    public BuilderWrapper<T> a(T e) { 
      b.add(e); 
      return this; 
    }

    public BuilderWrapper<T> a(Iterable<T> es) {
      b.addAll(es);
      return this;
    }

    public ImmutableList<T> e() { 
      return b.build(); 
    }
  }

  private static <T> ImmutableList<T> e() {
    return ImmutableList.of(); 
  }

  private static <T> BuilderWrapper<T> a(T e) { 
    return BuilderWrapper.n().a(e); 
  }

  private static <T> BuilderWrapper<T> a(Iterable<T> es) {
    return BuilderWrapper.n().a(es);
  }

  // returns "function NAME<TV, T1, ..., TN>
  //            (ARGS, map : [T1,...,TN]TV, x1:T1,.., xN:TN)
  //            returns (result : RESULTYPE)
  private FunctionDecl mkFunctionDecl(
      String name, 
      int n,
      Iterable<VariableDecl> args,
      Type resultType
  ) {
    return FunctionDecl.mk(
        ImmutableList.of(),
        Signature.mk(
            name,
            ImmutableList.builder()
                .addAll(AstUtils.ids("TV"))
                .addAll(nIds("T", n)).build(),
            ImmutableList.builder()
                .addAll(args)
                .add(mkMapDecl("map", n))
                .addAll(nVarDecl("x", n)).build(),
            ImmutableList.of(VariableDecl.mk(
                ImmutableList.of(),
                "result",
                resultType,
                ImmutableList.of))));
  }

  private VariableDecl mkVarDecl(String name, Type type) {
    return VariableDecl.mk(ImmutableList.of(), name, type);
  }

  // returns "NAME : [T1,...,TN]TV"
  private VariableDecl mkMapDecl(String name, int n) {
    return mkVarDecl(name, mkMapType(n));
  }

  // returns "[T1,...,TN]TV"
  private MapType mkMapType(int n) {
    return MapType.mk(nTypes(n), mkType("TV"));
  }

  // returns "NAME" (as a user type)
  private UserType mkType(String name) {
    return UserType.mk(name, ImmutableList.of());
  }

  // returns "p1, ..., pN"
  private <T> ImmutableList<T> nIds(String prefix, int n) {
    ImmutableList.Builder<T> ids = ImmutableList.builder();
    for (int i = 1; i <= n; ++i) ids.add(mkId(prefix + i));
    return ids.build();
  }

  // return "T1, ..., TN"
  private ImmutableList<Type> nTypes(int n) {
    ImmutableList.Builder<Type> types = ImmutableList.builder();
    for (int i = 1; i <= n; ++i) types.add(mkType("T" + i));
    return types.build();
  }

  // returns "x1 : T1, ...., xN : TN"
  private ImmutableList<VariableDecl> nVarDecl(String prefix, int n) {
    ImmutableList.Builder<VariableDecl> decls = ImmutableList.builder();
    for (int i = 1; i <= n; ++i) 
      decls.add(mkVarDecl("prefix" + n, mkType("T" + n)));
    return decls.build();
  }

  // returns "NAME(ARGS)" (as a function application)
  private AtomFun mkFun(String name, Iterable<Expr> args) {
    return AtomFun.mk(name, e(), a(args).e());
  }

  private AtomId mkId(String name) {
    return AtomId.mk(name, e());
  }

  private BinaryOp mkEq(Expr lhs, Expr rhs) {
    return BinaryOp.mk(BinaryOp.Type.EQ, lhs, rhs);
  }

  private BinaryOp mkImplies(Expr lhs, Expr rhs) {
    return BinaryOp.mk(BinaryOp.Type.IMPLIES, lhs, rhs);
  }
}
