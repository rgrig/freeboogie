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

  @Override
  public Boolean eval(
    AtomQuant atomQuant, 
    AtomQuant.QuantType quant, 
    ImmutableList<VariableDecl> vars, 
    ImmutableList<Attribute> attr, 
    Expr e
  ) {
    AstUtils.evalListOfVariableDecl(vars, this);
    e.eval(this);
    return memo(atomQuant, false);
  }

  @Override
  public Boolean eval(
    PrimitiveType primitiveType,
    PrimitiveType.Ptype ptype,
    int bits
  ) {
    return ptype == PrimitiveType.Ptype.ANY;
  }
}
