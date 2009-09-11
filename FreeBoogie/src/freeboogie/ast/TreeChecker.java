package freeboogie.ast;

import java.util.HashSet;

//DBG import java.io.PrintWriter;

/** Checks if AST is a tree (as opposed to a dag). */
public class TreeChecker extends Transformer {
  private HashSet<Ast> seen;
  private boolean duplicateFound;

  public TreeChecker() {
    seen = new HashSet<Ast>(100003);
  }

  public boolean isTree(Ast ast) {
    seen.clear();
    duplicateFound = false;
    ast.eval(this);
    // DBG System.out.println("seen size = " + seen.size());
    return !duplicateFound;
  }

  @Override
  public void enterNode(Ast ast) {
    /*
    if (seen.contains(ast)) {
      System.out.print("SHARED ");
      AstUtils.print(ast);
      System.out.println();
    }
    */
    duplicateFound |= !seen.add(ast);
    // DBG if (seen.size() % 5000 == 0) System.out.println(seen.size());
  }
}
