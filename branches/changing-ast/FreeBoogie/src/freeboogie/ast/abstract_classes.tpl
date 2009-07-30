vim:ft=java:

This template generates java classes for the abstract classes.

\abstract_classes{\file{\ClassName.java}
/** Do NOT edit. See abstract_classes.tpl instead. */
package freeboogie.ast;

public abstract class \ClassName extends \BaseName {
  // a more specific return type
  @Override
  public abstract \ClassName clone();
}
}