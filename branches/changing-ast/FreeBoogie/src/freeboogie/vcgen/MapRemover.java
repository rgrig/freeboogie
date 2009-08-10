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
      functions.add(mkFunctionDecl("$$select" + n, e(), mkTV()));

      // add "function $$updateN<TV, T1, ..., TN>
      //        (val : TV, map : [T1, ..., TN]TV, x1 : T1, ..., xN : TN)
      //        returns (result : [T1, ..., TN]TV);"
      functions.add(mkFunctionDecl(
          "$$update" + n, 
          a(mkVarDecl("val", mkTV())).e(),
          mkMapType(n)));

      // add "axiom<TV, T1, ..., TN>
      //        (forall m : [T1, ..., TN]TV, v : TV, x1 : T1, ..., xN : TN ::
      //          $$selectN($$updateN(v, m, x1, ..., xN), x1, ..., xN) == v
      //        );
      axioms.add(mkAxiom(
          a(mkMapDecl("m", n)).
          a(mkVarDecl("v", mkTV())).
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
            a(mkVarDecl("v", mkTV())).
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
                        a(nIds("y", n)).e())
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
      AtomMapSelect atomMapSelect, Atom atom, Exprs idx) {
    atom = (Atom)atom.eval(this);
    idx = (Exprs)idx.eval(this);
    int n = size(idx);
    arities.add(n);
    return AtomFun.mk("$$select" + n, null, Exprs.mk(atom, idx));
  }

  @Override
  public AtomFun eval(AtomMapUpdate atomMapUpdate, Atom atom, Exprs idx, Expr val) {
    atom = (Atom)atom.eval(this);
    idx = (Exprs)idx.eval(this);
    val = (Expr)val.eval(this);
    int n = size(idx);
    arities.add(n);
    return AtomFun.mk(
      "$$update" + n,
      null,
      Exprs.mk(val, Exprs.mk(atom, idx)));
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

    public GrowingList<T> a(Iterable<T> es) {
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

  private int size(Exprs exprs) {
    if (exprs == null) return 0;
    return 1 + size(exprs.getTail());
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
                .addAll(AstUtils.ids("TV")),
                .addAll(nIdentifiers("T", n)).build(),
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
    return MapType.mk(nTypes(n), mkTV());
  }

  // return "TV"
  private UserType mkTV() {
    return UserType.mk("TV", ImmutableList.of());
  }

  // returns "p1, ..., pN"
  private Identifiers nIdentifiers(String prefix, int n) {
    Identifiers result;
    for (result = null; n > 0; --n)
      result = Identifiers.mk(AtomId.mk(prefix + n, null), result);
    return result;
  }

  // returns "p1, ..., pN"
  private Exprs nExprs(String prefix, int n) {
    Exprs result;
    for (result = null; n > 0; --n)
      result = Exprs.mk(AtomId.mk(prefix + n, null), result);
    return result;
  }

  // return "T1, ..., TN"
  private TupleType nTypes(int n) {
    TupleType result;
    for (result = null; n > 0; --n)
      result = TupleType.mk(UserType.mk("T" + n, null), result);
    return result;
  }

  // returns "x1 : T1, ...., xN : TN"
  private VariableDecl nVarDecl(String prefix, int n, VariableDecl tail) {
    for (; n > 0; --n) {
      tail = VariableDecl.mk(
        null,
        prefix + n,
        UserType.mk("T" + n, null),
        null,
        tail);
    }
    return tail;
  }
}
