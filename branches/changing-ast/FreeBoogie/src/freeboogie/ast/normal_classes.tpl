vim:ft=java:
This template generates java classes for the normal classes.

\def{smt}{\if_primitive{\Membertype}{\MemberType}}
\def{mt}{\if_tagged{list}{ImmutableList<}{}\smt\if_tagged{list}{>}{}}
\def{mtn}{\mt \memberName}
\def{mtn_list}{\members[,]{\mtn}}

\classes{\if_terminal{
\file{\ClassName.java}
/** Do NOT edit. See normal_classes.tpl instead. */
package freeboogie.ast;

import java.math.BigInteger; // for AtomNum

import com.google.common.collect.ImmutableList;

/** @author rgrig */
public final class \ClassName extends \BaseName {
  \enums{public static enum \EnumName {\values[,]{\VALUE_NAME}}}
  \members{private final \mtn;}

  // === construction ===
  private \ClassName(\mtn_list) {
    this(\members[,]{\memberName}, FileLocation.unknown());
  }

  private \ClassName(\mtn_list, FileLocation location) {
    this.location = location;
    \members{
      \if_tagged{list}{
        this.\memberName = ImmutableList.<\smt>builder().addAll(\memberName).build();
      }{
        this.\memberName = \memberName;
      }
    }
    checkInvariant();
  }
  
  public static \ClassName mk(\mtn_list) {
    return new \ClassName(\members[,]{\memberName});
  }

  public static \ClassName mk(\mtn_list, FileLocation location) {
    return new \ClassName(\members[,]{\memberName}, location);
  }

  public void checkInvariant() {
    assert location != null;
    \members{
      \if_tagged{nonnull|list}{assert \memberName != null;}{}
    }
    \invariants{assert \inv;}
  }

  // === accessors ===
  \members{public \mtn() { return \memberName; }}

  @Override public ImmutableList<Ast> children() {
    if (children != null) return children;
    ImmutableList.Builder<Ast> builder_ = ImmutableList.builder();
    \children{
      \if_tagged{list}{
        builder_.addAll(\memberName);
      }{
        if (\memberName != null) builder_.add(\memberName);
      }
    }
    children = builder_.build();
    return children;
  }

  // === the Visitor pattern ===
  @Override
  public <R> R eval(Evaluator<R> evaluator) { 
    return evaluator.eval(this, \members[,]{\memberName}); 
  }

  // === others ===
  @Override
  public \ClassName clone() {
    \members{
      \if_primitive{
        \mt new\MemberName = this.\memberName;
      }{
        \if_tagged{list}{
          \mt new\MemberName = ImmutableList.copyOf(this.\memberName);
        }{
          \mt new\MemberName = this.\memberName == null? 
              null : this.\memberName.clone();
        }
      }
    }
    return \ClassName.mk(\members[, ]{new\MemberName}, location);
  }

  public String toString() {
    return "[\ClassName " + \members[ + " " + ]{\memberName} + "]";
  }
}}{}}

