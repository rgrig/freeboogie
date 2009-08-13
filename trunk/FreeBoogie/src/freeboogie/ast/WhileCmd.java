
/**
  This class is generated automatically from normal_classes.tpl. 
  Do not edit.
 */
package freeboogie.ast;
import java.math.BigInteger; // for AtomNum

/** @author rgrig */
public final class WhileCmd extends Command {


  private final Expr condition;
  private final LoopInvariant inv;
  private final Block stmt;



  // === Constructors and Factories ===
  private WhileCmd(Expr condition, LoopInvariant inv, Block stmt) {
    this.location = FileLocation.unknown();
    this.condition = condition; 
    this.inv = inv; 
    this.stmt = stmt; assert stmt != null;
  }

  private WhileCmd(Expr condition, LoopInvariant inv, Block stmt, FileLocation location) {
    this(condition,inv,stmt);
    assert location != null;
    this.location = location;
  }
  
  public static WhileCmd mk(Expr condition, LoopInvariant inv, Block stmt) {
    return new WhileCmd(condition, inv, stmt);
  }

  public static WhileCmd mk(Expr condition, LoopInvariant inv, Block stmt, FileLocation location) {
    return new WhileCmd(condition, inv, stmt, location);
  }

  // === Accessors ===

  public Expr getCondition() { return condition; }
  public LoopInvariant getInv() { return inv; }
  public Block getStmt() { return stmt; }

  // === The Visitor pattern ===
  @Override
  public <R> R eval(Evaluator<R> evaluator) { 
    return evaluator.eval(this, condition,inv,stmt); 
  }

  // === Others ===
  @Override
  public WhileCmd clone() {
    
      
        Expr newCondition = condition == null? 
          null : condition.clone();
      
    
      
        LoopInvariant newInv = inv == null? 
          null : inv.clone();
      
    
      
        Block newStmt = stmt == null? 
          null : stmt.clone();
      
    
    return WhileCmd.mk(newCondition, newInv, newStmt, location);
  }
  public String toString() {
    return "[WhileCmd " + 
                  condition + " " + inv + " " + stmt + "]";
  }
}

