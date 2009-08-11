vim:filetype=java:

\def{smt}{\if_primitive{\if_enum{\ClassName.}{}\Membertype}{\MemberType}}
\def{mt}{\if_tagged{list}{ImmutableList<}{}\smt\if_tagged{list}{>}{}}
\def{mtn}{\mt \memberName}
\def{mtn_list}{\members[,]{\mtn}}

\file{Transformer.java}
/** Do NOT edit. See transformer.tpl instead. */
package freeboogie.ast;

import java.math.BigInteger;
import java.util.ArrayDeque;
import java.util.Deque;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;

import freeboogie.tc.TcInterface;
import freeboogie.tc.TypeUtils;

/**
  Intended to be used as a base class by visitors that either
  only inspect the AST or transform the AST. If you want to
  inspect nodes of type X into then you should override {@code
  see(X x, ...)}. (Most of the time you also need to code
  visiting of the children.) If you want to replace (some) nodes
  of type X by something you should override {@code eval(X x,
  ...)} and return the substitution. This class will take care of
  path copying.
  
  @see freeboogie.ast.Evaluator
 */
public class Transformer extends Evaluator<Ast> {
  private final Ast NULL = AtomId.mk("<NULL>",null);
  private Deque<Ast> result = new ArrayDeque<Ast>();
  protected TcInterface tc;

  /** Returns the name of this transformer. */
  public String name() {
    return getClass().getName();
  }

  public Program process(Program p, TcInterface tc) {
    this.tc = tc;
    return TypeUtils.internalTypecheck((Program)p.eval(this), tc);
  }

  \classes{\if_terminal{
    public void see(\ClassName \className,\mtn_list) {
      Preconditions.checkNotNull(\className);
      boolean sameChildren = true;
      \members{
        \mt new\MemberName;
        \if_primitive{
          new\MemberName = \memberName;
        }{
          \if_tagged{list}{
            new\MemberName = evalListOf\MemberType(\memberName);
          }{
            new\MemberName = \memberName == null ? null :(\MemberType)\memberName.eval(this);
          }
          sameChildren &= new\MemberName == \memberName;
        }
      }

      if (!sameChildren) {
        result.removeFirst();
        result.addFirst(\ClassName.mk(\members[,]{new\MemberName},\className.loc()));
      }
    }
    
    @Override
    public Ast eval(\ClassName \className,\mtn_list) {
      // Deque<> doesn't support null elements
      result.addFirst(\className == null ? NULL : \className);
      enterNode(\className);
      see(\className,\members[,]{\memberName});
      exitNode(\className);
      Ast r = result.removeFirst();
      return r == NULL ? null : r;
    }
  }{}}

  \classes{
    public ImmutableList<\ClassName> evalListOf\ClassName(ImmutableList<\ClassName> l_) {
      boolean same_ = true;
      ImmutableList.Builder<\ClassName> builder_ = ImmutableList.builder();
      for (\ClassName c_ : l_) {
        \ClassName cc_ = (\ClassName) c_.eval(this);
        builder_.add(cc_);
        same_ &= cc_ == c_;
      }
      return same_? l_ : builder_.build();
    }
  }
}

\file{visitor.skeleton}
// You can copy and paste the text below when you define a visitor that
// needs to override most functions on the base class.

\classes{\if_terminal{  @Override
  public void see(\ClassName \className, \mtn_list) {
    assert false : "not implemented";
  }
}{}}

// *********

\classes{\if_terminal{  @Override
  public \ClassName see(\ClassName \className, \mtn_list) {
    assert false : "not implemented";
    return null;
  }
}{}}


