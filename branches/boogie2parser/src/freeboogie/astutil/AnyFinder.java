package freeboogie.astutil;

import com.google.common.collect.ImmutableList;
import genericutils.AssociativeOperator;

import freeboogie.ast.*;

/** 
  A helper class for {@code Boogie2Printer}. It tags each
  node with whether there is an "any" below, not hidden by a
  quantifier.
 */
public class AnyFinder extends AssociativeEvaluator<Boolean> {
  private static class Or implements AssociativeOperator<Boolean> {
    @Override public Boolean zero() { return false; }
    @Override public Boolean plus(Boolean a, Boolean b) { return a || b; }
  }

  public AnyFinder() {
    super(new Or());
  }

  @Override public Boolean eval(AtomQuant atomQuant) {
    AstUtils.evalListOfVariableDecl(atomQuant.vars(), this);
    atomQuant.expression().eval(this);
    return memo(atomQuant, false);
  }

  @Override public Boolean eval(PrimitiveType primitiveType) {
    return primitiveType.ptype() == PrimitiveType.Ptype.ANY;
  }
}
