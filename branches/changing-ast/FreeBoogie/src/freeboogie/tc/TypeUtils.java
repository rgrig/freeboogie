package freeboogie.tc;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Iterator;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.UnmodifiableIterator;
import genericutils.Err;

import freeboogie.ast.*;
import freeboogie.astutil.PrettyPrinter;

/**
 * Various utilities for handling {@code Type}. For the moment, it contains
 * a structural equality test that ignores AST locations. 
 *
 * @author rgrig 
 */
public final class TypeUtils {
  private TypeUtils() { /* forbid instantiation */ }
  
  // TODO: reuse this code for TypeChecker.sub. how?
  
  private static boolean eq(MapType a, MapType b) {
    return
      eq(a.elemType(), b.elemType()) &&
      eq(a.idxTypes(), b.idxTypes());
  }

  private static <T extends Type> boolean eq(
      ImmutableList<T> tla, 
      ImmutableList<T> tlb
  ) {
    if (tla.size() != tlb.size()) return false;
    UnmodifiableIterator<T> ia = tla.iterator();
    UnmodifiableIterator<T> ib = tlb.iterator();
    while (ia.hasNext()) if (!eq(ia.next(), ib.next())) return false;
    return true;
  }
  
  private static boolean eq(PrimitiveType a, PrimitiveType b) {
    return a.ptype() == b.ptype();
  }
  
  private static boolean eq(IndexedType a, IndexedType b) {
    return eq(a.param(), b.param()) && eq(a.type(), b.type());
  }
  
  private static boolean eq(UserType a, UserType b) {
    return a.name().equals(b.name());
  }
  
  /**
   * Recursively strip all dependent types from {@code a}.
   * @param a the type to strip of predicates
   * @return the type {@code a} striped of predicates
   */
  public static Type stripDep(Type a) {
    if (a instanceof MapType) {
      MapType sa = (MapType)a;
      return MapType.mk(
        stripDepTypes(sa.idxTypes()), 
        stripDep(sa.elemType()));
    } else if (a instanceof IndexedType) {
      IndexedType sa = (IndexedType)a;
      return IndexedType.mk(stripDep(sa.param()), stripDep(sa.type()));
    } else if (a instanceof DepType) return stripDep(((DepType)a).type());
    else return a;
  }

  // map stripDep
  public static ImmutableList<Type> stripDepTypes(ImmutableList<Type> tl) {
    ImmutableList.Builder<Type> b = ImmutableList.builder();
    for (Type t : tl) b.add(stripDep(t));
    return b.build();
  }

  public static ImmutableList<VariableDecl> stripDepDecls(
      ImmutableList<VariableDecl> dl
  ) {
    ImmutableList.Builder<VariableDecl> b = ImmutableList.builder();
    for (VariableDecl d : dl) b.add(stripDep(d));
    return b.build();
  }
  
  private static VariableDecl stripDep(VariableDecl va) {
    return VariableDecl.mk(
        null,
        va.name(), 
        stripDep(va.type()),
        va.typeArgs(),
        va.loc());
  }

  /**
   * Returns a signature that looks like {@code s} but has all predicates
   * of dependent types removed.
   * @param s the signature to strip
   * @return the signature {@code s} without dependent types
   */
  public static Signature stripDep(Signature s) {
    return Signature.mk(
        s.name(),
        s.typeArgs(),
        stripDepDecls(s.args()), 
        stripDepDecls(s.results()),
        s.loc());
  }
  
  /**
   * Compares two types for structural equality, ignoring locations
   * and predicates of dependent types.
   * @param a the first type
   * @param b the second type
   * @return whether the two types are structurally equal
   */
  public static boolean eq(Type a, Type b) {
    if (a == b) return true;
    if (a == null ^ b == null) return false;
    if (a instanceof MapType && b instanceof MapType)
      return eq((MapType)a, (MapType)b);
    else if (a instanceof PrimitiveType && b instanceof PrimitiveType)
      return eq((PrimitiveType)a, (PrimitiveType)b);
    else if (a instanceof IndexedType && b instanceof IndexedType)
      return eq((IndexedType)a, (IndexedType)b);
    else if (a instanceof UserType && b instanceof UserType)
      return eq((UserType)a, (UserType)b);
    else
      return false;
  }

  public static boolean eq(ImmutableList<Type> a, Type b) {
    return a.size() == 1 && eq(a.get(0), b);
  }
  public static boolean eq(Type a, ImmutableList<Type> b) {
    return eq(b, a);
  }

  /**
   * Returns whether {@code t} contains a dependent type.
   * @param t the type to check
   * @return whether {@code t} contains {@code DepType}
   */
  public static boolean hasDep(Type t) {
    if (t instanceof DepType) return true;
    else if (t instanceof MapType) {
      MapType st = (MapType)t;
      return 
        hasDep(st.elemType()) || 
        hasDep(st.idxTypes());
    } else if (t instanceof IndexedType) {
      IndexedType st = (IndexedType)t;
      return hasDep(st.param()) || hasDep(st.type());
    }
    return false;
  }

  public static boolean hasDep(ImmutableList<Type> tl) {
    for (Type t : tl) if (hasDep(t)) return true;
    return false;
  }

  /**
   * Pretty print a type.
   * @param t the type to pretty print
   * @return the string representation of {@code t}
   */
  public static String typeToString(Type t) {
    if (t == null) return "()";
    StringWriter sw = new StringWriter();
    PrettyPrinter pp = new PrettyPrinter();
    pp.writer(sw);
    t.eval(pp);
    return sw.toString();
  }
  
  public static boolean isInt(Type t) {
    return isPrimitive(t, PrimitiveType.Ptype.INT);
  }

  public static boolean isBool(Type t) {
    return isPrimitive(t, PrimitiveType.Ptype.BOOL);
  }

  public static boolean isPrimitive(Type t, PrimitiveType.Ptype p) {
    if (!(t instanceof PrimitiveType)) return false;
    PrimitiveType pt = (PrimitiveType)t;
    return pt.ptype() == p;
  }

  public static boolean isTypeVar(Type t) {
    assert false : "todo";
    return false;
  }

  /**
   * Typechecks {@code ast} using {@code tc}. Raises an internal
   * error if the typecheck fails.
   */
  public static Program internalTypecheck(Program ast, TcInterface tc) {
    if (!tc.process(ast).isEmpty()) {
      PrintWriter pw = new PrintWriter(System.out);
      PrettyPrinter pp = new PrettyPrinter();
      pp.writer(pw);
      ast.eval(pp);
      pw.flush();
      Err.internal("Invalid Boogie produced.");
    }
    return tc.getAST();
  }
}
