vim:ft=java:

Some useful macros:
\def{smt}{\if_primitive{\if_enum{\ClassName.}{}\Membertype}{\MemberType}}
\def{mt}{\if_tagged{list}{ImmutableList<}{}\smt\if_tagged{list}{>}{}}
\def{mtn}{\mt \memberName}
\def{mtn_list}{\members[,]{\mtn}}

\file{Substitutor.java}
/** Generated from substitutor.tpl. Do not edit */
package freeboogie.ast;

import java.util.Map;
import java.math.BigInteger;

import com.google.common.collect.ImmutableList;

/** Substitutes pieces of an AST with other AST pieces. */
public class Substitutor extends Transformer {
  private Map<Ast, Ast> subst;

  public Substitutor(Map<Ast, Ast> subst) {
    this.subst = subst;
  }

  \classes{\if_terminal{
    @Override public Ast eval(\ClassName \className) {
      Ast r = subst.get(\className);
      if (r != null) return r;
      boolean sameChildren = true;
      \members{
        \mt \memberName;
        \if_primitive{
          \memberName = \className.\memberName();
        }{
          \if_tagged{list}{
            \memberName = AstUtils.evalListOf\MemberType(
                \className.\memberName(), this);
          }{
            \memberName = \className.\memberName() == null? 
              null :
              (\MemberType) \className.\memberName().eval(this);
          }
          sameChildren &= \memberName == \className.\memberName();
        }
      }
      return sameChildren? \className : \ClassName.mk(\members[,]{\memberName}, \className.loc());
    }
  }{}}
}
