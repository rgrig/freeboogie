
/**
  This class is generated automatically from normal_classes.tpl. 
  Do not edit.
 */
package freeboogie.ast;
import java.math.BigInteger; // for AtomNum

/** @author rgrig */
public final class Attribute extends Ast {


  private final Exprs exprs;
  private final Attribute tail;

  private final String type;


  // === Constructors and Factories ===
  private Attribute(String type, Exprs exprs, Attribute tail) {
    this.location = FileLocation.unknown();
    this.type = type; assert type != null;
    this.exprs = exprs; 
    this.tail = tail; 
  }

  private Attribute(String type, Exprs exprs, Attribute tail, FileLocation location) {
    this(type,exprs,tail);
    assert location != null;
    this.location = location;
  }
  
  public static Attribute mk(String type, Exprs exprs, Attribute tail) {
    return new Attribute(type, exprs, tail);
  }

  public static Attribute mk(String type, Exprs exprs, Attribute tail, FileLocation location) {
    return new Attribute(type, exprs, tail, location);
  }

  // === Accessors ===

  public String getType() { return type; }
  public Exprs getExprs() { return exprs; }
  public Attribute getTail() { return tail; }

  // === The Visitor pattern ===
  @Override
  public <R> R eval(Evaluator<R> evaluator) { 
    return evaluator.eval(this, type,exprs,tail); 
  }

  // === Others ===
  @Override
  public Attribute clone() {
    
      
        String newType = type;
      
    
      
        Exprs newExprs = exprs == null? 
          null : exprs.clone();
      
    
      
        Attribute newTail = tail == null? 
          null : tail.clone();
      
    
    return Attribute.mk(newType, newExprs, newTail, location);
  }
  public String toString() {
    return "[Attribute " + 
                  type + " " + exprs + " " + tail + "]";
  }
}

