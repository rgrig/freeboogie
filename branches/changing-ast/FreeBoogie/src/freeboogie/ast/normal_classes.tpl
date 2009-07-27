vim:ft=java:
This template generates java classes for the normal classes.

\normal_classes{
\file{\ClassName.java}
/** Do NOT edit. See normal_classes.tpl instead. */
package freeboogie.ast;

import java.math.BigInteger; // for AtomNum

import com.google.common.collect.ImmutableList;

/** @author rgrig */
public final class \ClassName extends \BaseName {
  \enums{public static enum \EnumName {\values[,]{\VALUE_NAME}}}

  \members{
    private final
        \if_tagged{list}{ImmutableList<}{}\Membertype\if_tagged{list}{>}{}
        \memberName;
  }

  // === construction ===
  private \ClassName(\members[,]{\Membertype \memberName}) {
    this(\members[,]{\memberName}, FileLocation.unknown());
  }

  private \ClassName(\members[,]{\Membertype \memberName}, FileLocation location) {
    this.location = location;
    \members{this.\memberName = \memberName;}
    checkInvariant();
  }
  
  public static \ClassName mk(\members[,]{\Membertype \memberName}) {
    return new \ClassName(\members[,]{\memberName});
  }

  public static \ClassName mk(\members[,]{\Membertype \memberName}, FileLocation location) {
    return new \ClassName(\members[,]{\memberName}, location);
  }

  public void checkInvariant() {
    assert location != null;
    \members{
      \if_tagged{nonnull|list}{assert \memberName != null;}{}
    }
    \invariants{assert \inv_text;}
  }

  // === accessors ===
  \members{
    public \if_primitive{\Membertype}{\MemberType} \memberName() { 
      return \memberName;
    }
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
        \Membertype new\MemberName = \memberName;
      }{
        \MemberType new\MemberName = \memberName == null? 
          null : \memberName.clone();
      }
    }
    return \ClassName.mk(\members[, ]{new\MemberName}, location);
  }

  public String toString() {
    return "[\ClassName " + \members[ + " " + ]{\memberName} + "]";
  }
}

