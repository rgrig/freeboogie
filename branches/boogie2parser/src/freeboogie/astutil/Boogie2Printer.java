package freeboogie.astutil;

import java.io.PrintWriter;
import java.util.HashSet;

import com.google.common.base.Predicate;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterables;
import com.google.common.collect.Sets;

import freeboogie.ast.*;

/** Prints in the Boogie2 format. */
public class Boogie2Printer extends PrettyPrinter {
  private HashSet<String> newKeywords;
  private Evaluator<Boolean> anyFinder;

  public Boogie2Printer(PrintWriter pw) {
    writer(pw);

    anyFinder = new AnyFinder();

    newKeywords = Sets.newHashSet();
    newKeywords.add("else");
    newKeywords.add("end");
    newKeywords.add("then");

    quantRep.put(AtomQuant.QuantType.FORALL, "forall<any> ");
  }

  public void process(Declaration ast) {
    printPrelude();
    ast.eval(anyFinder);
    ast.eval(this);
  }

  private void printPrelude() {
    say("type name"); semi();
    say("type ref"); semi();

    say("const unique null : ref"); semi();
  }

  // This handles both block names and identifiers.
  // It is a bit of a hack because there's no guarantee that it doesn't
  // 'handle' too much.
  @Override protected void say(String s) {
    if (newKeywords.contains(s)) s = "id$" + s;
    super.say(s);
  }

  // === Overriden see methods ===


  @Override public void see(AtomFun atomFun) {
    say(ast.function());
    say("(");
    printList(", ", ast.args());
    say(")");
  }

  @Override public void see(AtomQuant atomQuant) {
    ++skipVar;
    say("(");
    if (ast.quant() == AtomQuant.QuantType.FORALL) {
      say("forall");
      boolean addAny = Iterables.any(
          ast.vars(), 
          new Predicate<VariableDecl>() {
            @Override public boolean apply(VariableDecl vd) {
              return anyFinder.get(vd);
          }});
      if (addAny) {
        say("<"); say("any"); say(">");
      }
    } else say("exists");
    say(" ");
    printList(", ", ast.vars());
    say(" :: ");
    printList(" ", ast.attr());
    ast.e().eval(this);
    say(")");
    --skipVar;
  }

  @Override public void see(AtomId atomId) {
    say(ast.id());
  }

  @Override public void see(Axiom axiom) {
    say("axiom ");
    ast.expr().eval(this);
    semi();
  }

  @Override public void see(AtomCast atomCast) {
    ast.e().eval(this);
  }

  @Override public void see(Signature signature) {
    ++skipVar;
    say(ast.name());
    if (anyFinder.get(ast.signature())) {
      say("<"); say("any"); say(">");
    }
    say("(");
    printList(", ", ast.args());
    say(")");
    if (ast.results ()!= null) {
      say(" returns (");
      printList(", ", ast.results());
      say(")");
    }
    --skipVar;
  }

  @Override public void see(ModifiesSpec modifiesSpec) {
    if (ast.free()) say("free ");
    say("modifies ");
    printList(", ", ast.ids());
    semi();
  }

  @Override public void see(PostSpec postSpec) {
    if (ast.free()) say("free ");
    say("ensures ");
    ast.expr().eval(this);
    semi();
  }

  @Override public void see(PreSpec preSpec) {
    if (ast.free()) say("free ");
    say("requires ");
    ast.expr().eval(this);
    semi();
  }

  @Override public void see(VariableDecl variableDecl) {
    if (skipVar==0) say("var ");
    say(ast.name());
    say(" : ");
    if (ast.typeArgs ()!= null) {
      say("<");
      printList(", ", ast.typeArgs());
      say(">");
    }
    ast.type().eval(this);
    if (ast.where ()!= null) {
      say(" ");
      say("where");
      say(" ");
      ast.where().eval(this);
    }
    if (skipVar==0) semi();
  }
  
}
