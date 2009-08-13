
/**
  This class is generated automatically from normal_classes.tpl. 
  Do not edit.
 */
package freeboogie.ast;
import java.math.BigInteger; // for AtomNum

/** @author rgrig */
public final class FunctionDecl extends Declaration {


  private final Attribute attr;
  private final Signature sig;
  private final Declaration tail;



  // === Constructors and Factories ===
  private FunctionDecl(Attribute attr, Signature sig, Declaration tail) {
    this.location = FileLocation.unknown();
    this.attr = attr; 
    this.sig = sig; assert sig != null;
    this.tail = tail; 
  }

  private FunctionDecl(Attribute attr, Signature sig, Declaration tail, FileLocation location) {
    this(attr,sig,tail);
    assert location != null;
    this.location = location;
  }
  
  public static FunctionDecl mk(Attribute attr, Signature sig, Declaration tail) {
    return new FunctionDecl(attr, sig, tail);
  }

  public static FunctionDecl mk(Attribute attr, Signature sig, Declaration tail, FileLocation location) {
    return new FunctionDecl(attr, sig, tail, location);
  }

  // === Accessors ===

  public Attribute getAttr() { return attr; }
  public Signature getSig() { return sig; }
  public Declaration getTail() { return tail; }

  // === The Visitor pattern ===
  @Override
  public <R> R eval(Evaluator<R> evaluator) { 
    return evaluator.eval(this, attr,sig,tail); 
  }

  // === Others ===
  @Override
  public FunctionDecl clone() {
    
      
        Attribute newAttr = attr == null? 
          null : attr.clone();
      
    
      
        Signature newSig = sig == null? 
          null : sig.clone();
      
    
      
        Declaration newTail = tail == null? 
          null : tail.clone();
      
    
    return FunctionDecl.mk(newAttr, newSig, newTail, location);
  }
  public String toString() {
    return "[FunctionDecl " + 
                  attr + " " + sig + " " + tail + "]";
  }
}

