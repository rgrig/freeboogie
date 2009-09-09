vim:ft=java:

\def{l}{ImmutableList<\ClassName>}
\def{lb}{ImmutableList.Builder<\ClassName>}

\file{AstUtils.java}
/** Do NOT edit. See utils.tpl instead. */
package freeboogie.ast;

import java.io.PrintWriter;

import com.google.common.collect.ImmutableList;

/** Provides shorthands for common operations in transformers. */
public class AstUtils {
  private AstUtils() { /* prevent instantiation and subclassing */ }

\classes{
  public static <T> \ClassName eval(\ClassName c, Evaluator<T> e) {
    return c == null ? null : (\ClassName) c.eval(e);
  }

  public static <T> \l evalListOf\ClassName(\l l, Evaluator<T> e) {
    boolean same = true;
    \lb builder = ImmutableList.builder();
    for (\ClassName c : l) {
      \ClassName cc = (\ClassName) c.eval(e);
      if (cc != null) builder.add(cc);
      same &= cc == c;
    }
    return same? l : builder.build();
  }

  public static \l cloneListOf\ClassName(\l l) {
    \lb builder = ImmutableList.builder();
    for (\ClassName c : l) builder.add(c.clone());
    return builder.build();
  }
}

  public static ImmutableList<Identifier> ids(String... ss) {
    ImmutableList.Builder<Identifier> r = ImmutableList.builder();
    for (String s : ss) r.add(Identifier.mk(s, ImmutableList.<Type>of()));
    return r.build();
  }

  public static ImmutableList<Identifier> ids(Iterable<String> ss) {
    ImmutableList.Builder<Identifier> r = ImmutableList.builder();
    for (String s : ss) r.add(Identifier.mk(s, ImmutableList.<Type>of()));
    return r.build();
  }

  public static Identifier mkId(String name) {
    return Identifier.mk(name, ImmutableList.<Type>of());
  }

  public static BinaryOp mkNotEq(Expr lhs, Expr rhs) {
    return BinaryOp.mk(BinaryOp.Op.NEQ, lhs, rhs);
  }

  public static BinaryOp mkEq(Expr lhs, Expr rhs) {
    return BinaryOp.mk(BinaryOp.Op.EQ, lhs, rhs);
  }

  public static BinaryOp mkImplies(Expr lhs, Expr rhs) {
    return BinaryOp.mk(BinaryOp.Op.IMPLIES, lhs, rhs);
  }

  public static void print(Ast ast) {
    PrintWriter pw = new PrintWriter(System.out);
    PrettyPrinter pp = new PrettyPrinter();
    pp.writer(pw);
    ast.eval(pp);
    pw.flush();
  }
}
