
/**
  This class is generated automatically from normal_classes.tpl. 
  Do not edit.
 */
package freeboogie.ast;
import java.math.BigInteger; // for AtomNum

/** @author rgrig */
public final class LoopInvariant extends Ast {


  private final Expr expr;
  private final LoopInvariant tail;

  private final boolean free;


  // === Constructors and Factories ===
  private LoopInvariant(boolean free, Expr expr, LoopInvariant tail) {
    this.location = FileLocation.unknown();
    this.free = free; 
    this.expr = expr; assert expr != null;
    this.tail = tail; 
  }

  private LoopInvariant(boolean free, Expr expr, LoopInvariant tail, FileLocation location) {
    this(free,expr,tail);
    assert location != null;
    this.location = location;
  }
  
  public static LoopInvariant mk(boolean free, Expr expr, LoopInvariant tail) {
    return new LoopInvariant(free, expr, tail);
  }

  public static LoopInvariant mk(boolean free, Expr expr, LoopInvariant tail, FileLocation location) {
    return new LoopInvariant(free, expr, tail, location);
  }

  // === Accessors ===

  public boolean getFree() { return free; }
  public Expr getExpr() { return expr; }
  public LoopInvariant getTail() { return tail; }

  // === The Visitor pattern ===
  @Override
  public <R> R eval(Evaluator<R> evaluator) { 
    return evaluator.eval(this, free,expr,tail); 
  }

  // === Others ===
  @Override
  public LoopInvariant clone() {
    
      
        boolean newFree = free;
      
    
      
        Expr newExpr = expr == null? 
          null : expr.clone();
      
    
      
        LoopInvariant newTail = tail == null? 
          null : tail.clone();
      
    
    return LoopInvariant.mk(newFree, newExpr, newTail, location);
  }
  public String toString() {
    return "[LoopInvariant " + 
                  free + " " + expr + " " + tail + "]";
  }
}

