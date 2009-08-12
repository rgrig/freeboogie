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


  @Override
  public void see(
    AtomFun atomFun, 
    String function, 
    ImmutableList<Type> types, 
    ImmutableList<Expr> args
  ) {
    say(function);
    say("(");
    printList(", ", args);
    say(")");
  }

  @Override
  public void see(
    AtomQuant atomQuant, 
    AtomQuant.QuantType quant, 
    ImmutableList<VariableDecl> vars, 
    ImmutableList<Attribute> attr, 
    Expr e
  ) {
    ++skipVar;
    say("(");
    if (quant == AtomQuant.QuantType.FORALL) {
      say("forall");
      boolean addAny = Iterables.any(
          vars, 
          new Predicate<VariableDecl>() {
            @Override public boolean apply(VariableDecl vd) {
              return anyFinder.get(vd);
          }});
      if (addAny) {
        say("<"); say("any"); say(">");
      }
    } else say("exists");
    say(" ");
    printList(", ", vars);
    say(" :: ");
    printList(" ", attr);
    e.eval(this);
    say(")");
    --skipVar;
  }

  @Override
  public void see(AtomId atomId, String id, ImmutableList<Type> types) {
    say(id);
  }

  @Override
  public void see(
    Axiom axiom, 
    ImmutableList<Attribute> attr,
    String name,
    ImmutableList<AtomId> typeVars, 
    Expr expr
  ) {
    say("axiom ");
    expr.eval(this);
    semi();
  }

  @Override
  public void see(AtomCast atomCast, Expr e, Type type) {
    e.eval(this);
  }

  @Override
  public void see(IndexedType genericType, Type param, Type type) {
    type.eval(this);
  }

  @Override
  public void see(
    Signature signature, 
    String name, 
    ImmutableList<AtomId> typeArgs,
    ImmutableList<VariableDecl> args, 
    ImmutableList<VariableDecl> results
  ) {
    ++skipVar;
    say(name);
    if (anyFinder.get(signature)) {
      say("<"); say("any"); say(">");
    }
    say("(");
    printList(", ", args);
    say(")");
    if (results != null) {
      say(" returns (");
      printList(", ", results);
      say(")");
    }
    --skipVar;
  }

  @Override
  public void see(
      ModifiesSpec modifiesSpec, 
      boolean free,
      ImmutableList<AtomId> ids
  ) {
    if (free) say("free ");
    say("modifies ");
    printList(", ", ids);
    semi();
  }

  @Override
  public void see(
      PostSpec postSpec, 
      boolean free,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    if (free) say("free ");
    say("ensures ");
    expr.eval(this);
    semi();
  }

  @Override
  public void see(
      PreSpec preSpec, 
      boolean free,
      ImmutableList<AtomId> typeArgs,
      Expr expr
  ) {
    if (free) say("free ");
    say("requires ");
    expr.eval(this);
    semi();
  }

  @Override
  public void see(
    VariableDecl variableDecl, 
    ImmutableList<Attribute> attr,
    String name, 
    Type type, 
    ImmutableList<AtomId> typeArgs
  ) {
    if (skipVar==0) say("var ");
    say(name);
    say(" : ");
    if (typeArgs != null) {
      say("<");
      printList(", ", typeArgs);
      say(">");
    }
    type.eval(this);
    if (skipVar==0) semi();
  }
  
}
