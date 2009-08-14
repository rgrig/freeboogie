vim:ft=java:

\def{l}{ImmutableList<\ClassName>}
\def{lb}{ImmutableList.Builder<\ClassName>}

\file{AstUtils.java}
/** Do NOT edit. See utils.tpl instead. */
package freeboogie.ast;

import com.google.common.collect.ImmutableList;

/** Provides shorthands for common operations in transformers. */
public class AstUtils {
  private AstUtils() { /* prevent instantiation and subclassing */ }

  public static ImmutableList<AtomId> ids(String... ss) {
    ImmutableList.Builder<AtomId> r = ImmutableList.builder();
    for (String s : ss) r.add(AtomId.mk(s, ImmutableList.<Type>of()));
    return r.build();
  }

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

}
