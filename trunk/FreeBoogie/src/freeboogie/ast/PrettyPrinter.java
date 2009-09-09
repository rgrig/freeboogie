package freeboogie.ast;

import java.io.IOException;
import java.io.Writer;
import java.math.BigInteger;
import java.util.HashMap;
import java.util.Iterator;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;
import genericutils.Err;

import freeboogie.Main;
import freeboogie.tc.TcInterface;

/**
 * Prints AST nodes in a readable (and parseable) way.
 *
 * @author rgrig 
 */
@SuppressWarnings("unused") // lots of unused parameters
public class PrettyPrinter extends Transformer {
  private int indent = 2; // indentation spaces
  
  private Writer writer; // where the output is sent
  
  /**
   * The nesting level:
   * Should be zero when I start and when I finish printing.
   */ 
  protected int indentLevel;
  
  protected int skipVar; // if >0 then skip "var "

  // should types in a TupleType be prefixed by "`"?
  private boolean prefixByBq;
  
  // ready made strings to be printed for enums
  protected HashMap<AssertAssumeCmd.CmdType,String> cmdRep ;
  protected HashMap<BooleanLiteral.Type,String> atomRep;
  protected HashMap<Quantifier.QuantType,String> quantRep;
  protected HashMap<BinaryOp.Op,String> binRep;
  protected HashMap<PrimitiveType.Ptype,String> typeRep;
  protected HashMap<UnaryOp.Op,String> unRep;

  private void initConstants() {
    cmdRep = Maps.newHashMap();
    atomRep = Maps.newHashMap();
    quantRep = Maps.newHashMap();
    binRep = Maps.newHashMap();
    typeRep = Maps.newHashMap();
    unRep = Maps.newHashMap();

    cmdRep.put(AssertAssumeCmd.CmdType.ASSERT, "assert ");
    cmdRep.put(AssertAssumeCmd.CmdType.ASSUME, "assume ");
    atomRep.put(BooleanLiteral.Type.FALSE, "false");
    atomRep.put(BooleanLiteral.Type.TRUE, "true");
    quantRep.put(Quantifier.QuantType.EXISTS, "exists ");
    quantRep.put(Quantifier.QuantType.FORALL, "forall ");
    binRep.put(BinaryOp.Op.AND, " && ");
    binRep.put(BinaryOp.Op.DIV, " / ");
    binRep.put(BinaryOp.Op.EQ, " == ");
    binRep.put(BinaryOp.Op.EQUIV, " <==> ");
    binRep.put(BinaryOp.Op.GE, " >= ");
    binRep.put(BinaryOp.Op.GT, " > ");
    binRep.put(BinaryOp.Op.IMPLIES, " ==> ");
    binRep.put(BinaryOp.Op.LE, " <= ");
    binRep.put(BinaryOp.Op.LT, " < ");
    binRep.put(BinaryOp.Op.MINUS, " - ");
    binRep.put(BinaryOp.Op.MOD, " % ");
    binRep.put(BinaryOp.Op.MUL, " * ");
    binRep.put(BinaryOp.Op.NEQ, " != ");
    binRep.put(BinaryOp.Op.OR, " || ");
    binRep.put(BinaryOp.Op.PLUS, " + ");
    binRep.put(BinaryOp.Op.SUBTYPE, " <: ");
    typeRep.put(PrimitiveType.Ptype.BOOL, "bool");
    typeRep.put(PrimitiveType.Ptype.INT, "int");
    typeRep.put(PrimitiveType.Ptype.ERROR, "?");
    unRep.put(UnaryOp.Op.MINUS, "-");
    unRep.put(UnaryOp.Op.NOT, "!");
  }
  
  public PrettyPrinter() {
    indent = 2;
    indentLevel = 0;
    skipVar = 0;
    prefixByBq = false;
    initConstants();
  }

  @Override public Program process(Program program, TcInterface typechecker) {
    program.eval(this);
    return program;
  }

  public void writer(Writer writer) {
    Preconditions.checkNotNull(writer);
    this.writer = writer;
  }

  /** Swallow exceptions. */
  protected void say(String s) {
    try {
      writer.write(s);
    } catch (IOException e) {
      Err.help("Can't pretty print. Nevermind.");
    }
  }
  
  /** Send a newline to the writer. */
  protected void nl() {
    say("\n"); // TODO: handle Windows?
    for (int i = indent * indentLevel; i > 0; --i) say(" ");
  }
  
  /** End command. */
  protected void semi() {
    say(";"); nl();
  }
  
  // === the visiting methods ===
  
  @Override public void see(MapType ast) {
    say("[");
    assert !prefixByBq;
    printList(", ", ast.idxTypes());
    say("]");
    ast.elemType().eval(this);
  }

  @Override public void see(AssertAssumeCmd ast) {
    for (String l : ast.labels()) {
      say(l);
      say(": ");
    }
    say(cmdRep.get(ast.type()));
    if (!ast.typeArgs().isEmpty()) {
      say("<");
      printList(", ", ast.typeArgs());
      say(">");
    }
    ast.expr().eval(this);
    semi();
  }

  @Override public void see(AssignmentCmd ast) {
    for (String l : ast.labels()) {
      say(l);
      say(": ");
    }
    for (int i = 0; i < ast.assignments().size(); ++i) {
      if (i != 0) say(", ");
      ast.assignments().get(i).lhs().eval(this);
    }
    say(" := ");
    for (int i = 0; i < ast.assignments().size(); ++i) {
      if (i != 0) say(", ");
      ast.assignments().get(i).rhs().eval(this);
    }
    semi();
  }

  @Override public void see(FunctionApp ast) {
    say(ast.function());
    if (!ast.types().isEmpty()) {
      say("<");
      assert !prefixByBq;
      prefixByBq = true;
      printList(", ", ast.types());
      prefixByBq = false;
      say(">");
    }
    say("(");
    printList(", ", ast.args());
    say(")");
  }

  @Override public void see(Identifier ast) {
    say(ast.id());
    if (!ast.types().isEmpty()) {
      say("<");
      assert !prefixByBq;
      prefixByBq = true;
      printList(", ", ast.types());
      prefixByBq = false;
      say(">");
    }
  }

  @Override public void see(MapSelect ast) {
    ast.map().eval(this);
    say("[");
    printList(", ", ast.idx());
    say("]");
  }

  @Override public void see(MapUpdate ast) {
    ast.map().eval(this);
    say("[");
    printList(", ", ast.idx());
    say(" := ");
    ast.val().eval(this);
    say("]");
  }

  @Override public void see(BooleanLiteral ast) {
    say(atomRep.get(ast.val()));
  }

  @Override public void see(NumberLiteral ast) {
    say(ast.value().toString());
  }

  @Override public void see(OldExpr ast) {
    say("old(");
    ast.expr().eval(this);
    say(")");
  }

  @Override public void see(Quantifier ast) {
    ++skipVar;
    say("(");
    say(quantRep.get(ast.quant()));
    printList(", ", ast.vars());
    say(" :: ");
    printList(" ", ast.attributes());
    ast.expression().eval(this);
    say(")");
    --skipVar;
  }

  @Override public void see(Axiom ast) {
    say("axiom");
    if (!ast.typeArgs().isEmpty()) {
      say("<");
      printList(", ", ast.typeArgs());
      say(">");
    }
    say(" ");
    ast.expr().eval(this); semi();
  }

  @Override public void see(BinaryOp ast) {
    say("(");
    ast.left().eval(this);
    say(binRep.get(ast.op()));
    ast.right().eval(this);
    say(")");
  }

  @Override public void see(Block ast) {
    printList("", ast.commands());
  }

  @Override public void see(Body ast) {
    say(" {");
    ++indentLevel; nl();
    printList("", ast.vars());
    ast.block().eval(this);
    --indentLevel; nl();
    say("}");
    nl();
  }

  @Override public void see(CallCmd ast) {
    for (String l : ast.labels()) {
      say(l);
      say(": ");
    }
    say("call ");
    if (!ast.results().isEmpty()) {
      printList(", ", ast.results());
      say(" := ");
    }
    say(ast.procedure());
    if (!ast.types().isEmpty()) {
      say("<");
      assert !prefixByBq;
      prefixByBq = true;
      printList(", ", ast.types());
      prefixByBq = false;
      say(">");
    }
    say("(");
    printList(", ", ast.args());
    say(")");
    semi();
  }

  @Override public void see(ConstDecl ast) {
    say("const ");
    printList(" ", ast.attributes());
    if (ast.uniq()) say("unique ");
    say(ast.name());
    say(" : ");
    ast.type().eval(this);
    semi();
  }

  public <T extends Ast> void printList(String sep, ImmutableList<T> list) {
    Iterator<T> i = list.iterator();
    if (i.hasNext()) i.next().eval(this);
    while (i.hasNext()) {
      say(sep);
      i.next().eval(this);
    }
  }

  @Override public void see(FunctionDecl ast) {
    say("function ");
    printList(" ", ast.attributes());
    ast.sig().eval(this);
    semi();
  }

  @Override public void see(HavocCmd ast) {
    for (String l : ast.labels()) {
      say(l);
      say(": ");
    }
    say("havoc ");
    printList(", ", ast.ids());
    semi();
  }

  @Override public void see(Implementation ast) {
    say("implementation ");
    printList(" ", ast.attributes());
    ast.sig().eval(this);
    ast.body().eval(this);
    nl();
  }

  @Override public void see(PrimitiveType ast) {
    say(typeRep.get(ast.ptype()));
  }

  @Override public void see(Procedure ast) {
    say("procedure ");
    printList(" ", ast.attributes());
    ast.sig().eval(this);
    say(";");
    printSpecs(ast.preconditions());
    printSpecs(ast.modifies());
    printSpecs(ast.postconditions());
    nl();
  }

  private void printSpecs(ImmutableList<? extends Specification> specs) {
    ++indentLevel; 
    for (Specification s : specs) s.eval(this);
    --indentLevel;
  }

  @Override public void see(Signature ast) {
    ++skipVar;
    say(ast.name());
    if (!ast.typeArgs().isEmpty()) {
      say("<");
      printList(", ", ast.typeArgs());
      say(">");
    }
    say("(");
    printList(", ", ast.args());
    say(")");
    if (!ast.results().isEmpty()) {
      say(" returns (");
      printList(", ", ast.results());
      say(")");
    }
    --skipVar;
  }

  @Override public void see(ModifiesSpec ast) {
    if (ast.free()) say("free ");
    say("modifies ");
    printList(", ", ast.ids());
    semi();
  }

  @Override public void see(PostSpec ast) {
    if (ast.free()) say("free ");
    say("ensures");
    if (!ast.typeArgs().isEmpty()) {
      say("<");
      printList(", ", ast.typeArgs());
      say(">");
    }
    say(" ");
    ast.expr().eval(this);
    semi();
  }

  @Override public void see(PreSpec ast) {
    if (ast.free()) say("free ");
    say("requires");
    if (!ast.typeArgs().isEmpty()) {
      say("<");
      printList(", ", ast.typeArgs());
      say(">");
    }
    say(" ");
    ast.expr().eval(this);
    semi();
  }


  @Override public void see(TypeDecl ast) {
    say("type ");
    printList(" ", ast.attributes());
    if (ast.finite()) {
      say("finite");
      say(" ");
    }
    say(ast.name());
    say(" ");
    printList(" ", ast.typeArgs());
    if (ast.type ()!= null) {
      say(" = ");
      ast.type().eval(this);
    }
    semi();
  }

  @Override public void see(UnaryOp ast) {
    say(unRep.get(ast.op()));
    ast.expr().eval(this);
  }

  @Override public void see(UserType ast) {
    say("(");
    say(ast.name());
    say(" ");
    printList(" ", ast.typeArgs());
    say(")");
  }

  @Override public void see(TupleType ast) {
    say("(");
    printList(", ", ast.types());
    say(")");
  }

  @Override public void see(VariableDecl ast) {
    if (skipVar==0) say("var ");
    printList(" ", ast.attributes());
    say(ast.name());
    if (!ast.typeArgs().isEmpty()) {
      say("<");
      printList(", ", ast.typeArgs());
      say(">");
    }
    say(" : ");
    ast.type().eval(this);
    if (ast.where ()!= null) {
      say(" ");
      say("where");
      say(" ");
      ast.where().eval(this);
    }
    if (skipVar==0) semi();
  }
  
  @Override public void see(Attribute ast) {
    say("{");
    say(":"); say(ast.type());
    say(" ");
    printList(" ", ast.exprs());
    say("} ");
  }

  @Override public void see(BreakCmd ast) {
    assert false : "todo";
  }

  @Override public void see(GotoCmd ast) {
    for (String l : ast.labels()) {
      say(l);
      say(": ");
    }
    if (ast.successors().isEmpty())
      say("return");
    else {
      say("goto ");
      for (int i = 0; i < ast.successors().size(); ++i) {
        if (i != 0) say(", ");
        say(ast.successors().get(i));
      }
    }
    semi();
  }

  @Override public void see(WhileCmd ast) {
    assert false : "not implemented";
  }
}
