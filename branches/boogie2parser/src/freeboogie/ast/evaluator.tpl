vim:ft=java:

This is the generic interface for a visitor that can return
a value. As a convenience, the object is also deconstructed
in the class. The original object is sent nevertheless because
we may want to use it.

Some useful macros:
\def{smt}{\if_primitive{\if_enum{\ClassName.}{}\Membertype}{\MemberType}}
\def{mt}{\if_tagged{list}{ImmutableList<}{}\smt\if_tagged{list}{>}{}}
\def{mtn}{\mt \memberName}
\def{mtn_list}{\members[,]{\mtn}}

\file{Evaluator.java}
/** Do NOT edit. See evaluator.tpl instead. */
package freeboogie.ast;

import java.math.BigInteger;
import java.util.HashMap;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;

/**
  Use as a base class when you want to compute a value of type
  {@code R} for each node. An example is the typechecker.
 */
public class Evaluator<R> {
  protected HashMap<Ast, R> evalCache = Maps.newHashMap();
  protected R memo(Ast a, R r) { 
    if (r != null) evalCache.put(a, r);
    return r;
  }
  public R get(Ast a) { 
    R r = evalCache.get(a);
    Preconditions.checkState(r != null, 
        "Only call get() if you know that that the value was computed."
        + " Otherwise use eval().");
    return r; 
  }

  \classes{\if_terminal{
    public R eval(\ClassName \className,\mtn_list) {
      R result_ = evalCache.get(\className);
      if (result_ != null) return result_;
      enterNode(\className);
      for (Ast child_ : \className.children()) child_.eval(this);
      exitNode(\className);
      return null;
    }
  }{}}

  // === hooks for derived classes ===
  public void enterNode(Ast ast) { /* do nothing */ }
  public void exitNode(Ast ast) { /* do nothing */ }
}

\file{AssociativeEvaluator.java}
/** Do NOT edit. See evaluator.tpl instead. */
package freeboogie.ast;

import java.math.BigInteger;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;
import genericutils.AssociativeOperator;

public class AssociativeEvaluator<R> extends Evaluator<R> {
  protected AssociativeOperator<R> assocOp;
  public AssociativeEvaluator(AssociativeOperator<R> assocOp) {
    this.assocOp = assocOp;
  }
  \classes{\if_terminal{
    @Override public R eval(\ClassName \className,\mtn_list) {
      R result_ = evalCache.get(\className);
      if (result_ != null) return result_;
      result_ = assocOp.zero();
      enterNode(\className);
      for (Ast child_ : \className.children())
        result_ = assocOp.plus(result_,child_.eval(this));
      exitNode(\className);
      return memo(\className, result_);
    }
  }{}}
}
