package freeboogie.astutil;

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
import freeboogie.ast.*;
import static freeboogie.cli.FbCliOptionsInterface.BoogieVersionOpt;

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
  protected HashMap<AtomLit.AtomType,String> atomRep;
  protected HashMap<AtomQuant.QuantType,String> quantRep;
  protected HashMap<BinaryOp.Op,String> binRep;
  protected HashMap<PrimitiveType.Ptype,String> typeRep;
  protected HashMap<UnaryOp.Op,String> unRep;

  protected BoogieVersionOpt boogieVersion;
  
  private void initConstants() {
    cmdRep = Maps.newHashMap();
    atomRep = Maps.newHashMap();
    quantRep = Maps.newHashMap();
    binRep = Maps.newHashMap();
    typeRep = Maps.newHashMap();
    unRep = Maps.newHashMap();

    cmdRep.put(AssertAssumeCmd.CmdType.ASSERT, "assert ");
    cmdRep.put(AssertAssumeCmd.CmdType.ASSUME, "assume ");
    atomRep.put(AtomLit.AtomType.FALSE, "false");
    atomRep.put(AtomLit.AtomType.TRUE, "true");
    atomRep.put(AtomLit.AtomType.NULL, "null");
    quantRep.put(AtomQuant.QuantType.EXISTS, "exists ");
    quantRep.put(AtomQuant.QuantType.FORALL, "forall ");
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
    typeRep.put(PrimitiveType.Ptype.ANY, "any");
    typeRep.put(PrimitiveType.Ptype.BOOL, "bool");
    typeRep.put(PrimitiveType.Ptype.INT, "int");
    typeRep.put(PrimitiveType.Ptype.NAME, "name");
    typeRep.put(PrimitiveType.Ptype.REF, "ref");
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

  public void writer(Writer writer) {
    Preconditions.checkNotNull(writer);
    this.writer = writer;
  }

  public void boogieVersion(BoogieVersionOpt boogieVersion) {
    Preconditions.checkNotNull(boogieVersion);
    this.boogieVersion = boogieVersion;
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
  
  @Override
  public void see(MapType arrayType, ImmutableList<Type> idxType, Type elemType) {
    say("[");
    assert !prefixByBq;
    printList(", ", idxType);
    say("]");
    elemType.eval(this);
  }

  @Override public void see(
    AssertAssumeCmd assertAssumeCmd, 
    ImmutableList<String> labels,
    AssertAssumeCmd.CmdType type, 
    ImmutableList<AtomId> typeVars, 
    Expr expr
  ) {
    for (String l : labels) {
      say(l);
      say(": ");
    }
    say(cmdRep.get(type));
    if (!typeVars.isEmpty()) {
      say("<");
      printList(", ", typeVars);
      say(">");
    }
    expr.eval(this);
    semi();
  }

  @Override
  public void see(
      AssignmentCmd assignmentCmd, 
      ImmutableList<String> labels, 
      AtomId lhs, 
      Expr rhs
  ) {
    for (String l : labels) {
      say(l);
      say(": ");
    }
    lhs.eval(this);
    say(" := ");
    rhs.eval(this);
    semi();
  }

  @Override
  public void see(AtomCast atomCast, Expr e, Type type) {
    say("cast(");
    e.eval(this);
    say(", ");
    type.eval(this);
    say(")");
  }

  @Override
  public void see(
    AtomFun atomFun, 
    String function, 
    ImmutableList<Type> types, 
    ImmutableList<Expr> args
  ) {
    say(function);
    if (!types.isEmpty()) {
      say("<");
      assert !prefixByBq;
      prefixByBq = true;
      printList(", ", types);
      prefixByBq = false;
      say(">");
    }
    say("(");
    printList(", ", args);
    say(")");
  }

  @Override
  public void see(AtomId atomId, String id, ImmutableList<Type> types) {
    say(id);
    if (!types.isEmpty()) {
      say("<");
      assert !prefixByBq;
      prefixByBq = true;
      printList(", ", types);
      prefixByBq = false;
      say(">");
    }
  }

  @Override
  public void see(
      AtomMapSelect atomMapSelect, 
      Atom atom, 
      ImmutableList<Expr> idx
  ) {
    atom.eval(this);
    say("[");
    printList(", ", idx);
    say("]");
  }

  @Override
  public void see(
      AtomMapUpdate atomMapUpdate, 
      Atom atom, 
      ImmutableList<Expr> idx, 
      Expr val
  ) {
    atom.eval(this);
    say("[");
    printList(", ", idx);
    say(" := ");
    val.eval(this);
    say("]");
  }

  @Override
  public void see(AtomLit atomLit, AtomLit.AtomType val) {
    say(atomRep.get(val));
  }

  @Override
  public void see(AtomNum atomNum, BigInteger val) {
    say(val.toString());
  }

  @Override
  public void see(AtomOld atomOld, Expr e) {
    say("old(");
    e.eval(this);
    say(")");
  }

  @Override
  public void see(
    AtomQuant atomQuant, 
    AtomQuant.QuantType quant, 
    ImmutableList<VariableDecl> vars, 
    ImmutableList<Attribute> attributes,
    Expr e
  ) {
    ++skipVar;
    say("(");
    say(quantRep.get(quant));
    printList(", ", vars);
    say(" :: ");
    printList(" ", attributes);
    e.eval(this);
    say(")");
    --skipVar;
  }

  @Override
  public void see(
    Axiom axiom, 
    ImmutableList<Attribute> attributes,
    String name,
    ImmutableList<AtomId> typeArgs, 
    Expr expr
  ) {
    say("axiom");
    switch (boogieVersion) {
      case TWO: say(" "); say(name); break;
    }
    if (!typeArgs.isEmpty()) {
      say("<");
      printList(", ", typeArgs);
      say(">");
    }
    switch (boogieVersion) {
      case TWO: say(":"); break;
    }
    say(" ");
    expr.eval(this); semi();
  }

  @Override
  public void see(BinaryOp binaryOp, BinaryOp.Op op, Expr left, Expr right) {
    say("(");
    left.eval(this);
    say(binRep.get(op));
    right.eval(this);
    say(")");
  }

  @Override
  public void see(Block block, ImmutableList<Command> commands) {
    printList("", commands);
  }

  @Override
  public void see(
      Body body, 
      ImmutableList<VariableDecl> vars, 
      Block block
  ) {
    say(" {");
    ++indentLevel; nl();
    printList("", vars);
    block.eval(this);
    --indentLevel; nl();
    say("}");
    nl();
  }

  @Override
  public void see(
      CallCmd callCmd, 
      ImmutableList<String> labels,
      String procedure, 
      ImmutableList<Type> types, 
      ImmutableList<AtomId> results,
      ImmutableList<Expr> args
  ) {
    for (String l : labels) {
      say(l);
      say(": ");
    }
    say("call ");
    if (!results.isEmpty()) {
      printList(", ", results);
      say(" := ");
    }
    say(procedure);
    if (!types.isEmpty()) {
      say("<");
      assert !prefixByBq;
      prefixByBq = true;
      printList(", ", types);
      prefixByBq = false;
      say(">");
    }
    say("(");
    printList(", ", args);
    say(")");
    semi();
  }

  @Override
  public void see(
    ConstDecl constDecl, 
    ImmutableList<Attribute> attributes,
    String name, 
    Type type, 
    boolean uniq
  ) {
    say("const ");
    printList(" ", attributes);
    if (uniq) say("unique ");
    say(name);
    say(" : ");
    type.eval(this);
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

  @Override
  public void see(
      FunctionDecl function,
      ImmutableList<Attribute> attributes,
      Signature sig
  ) {
    say("function ");
    printList(" ", attributes);
    sig.eval(this);
    semi();
  }

  @Override
  public void see(
      HavocCmd havocCmd, 
      ImmutableList<String> labels,
      ImmutableList<AtomId> ids
  ) {
    for (String l : labels) {
      say(l);
      say(": ");
    }
    say("havoc ");
    printList(", ", ids);
    semi();
  }

  @Override
  public void see(
    Implementation implementation, 
    ImmutableList<Attribute> attributes,
    Signature sig, 
    Body body 
  ) {
    say("implementation ");
    printList(" ", attributes);
    sig.eval(this);
    body.eval(this);
    nl();
  }

  @Override
  public void see(
    PrimitiveType primitiveType,
    PrimitiveType.Ptype ptype,
    int bits
  ) {
    say(typeRep.get(ptype));
  }

  @Override
  public void see(
      Procedure procedure, 
      ImmutableList<Attribute> attr,
      Signature sig, 
      ImmutableList<PreSpec> preconditions,
      ImmutableList<PostSpec> postconditions,
      ImmutableList<ModifiesSpec> modifies
  ) {
    say("procedure ");
    printList(" ", attr);
    sig.eval(this);
    say(";");
    printSpecs(preconditions);
    printSpecs(modifies);
    printSpecs(postconditions);
    nl();
  }

  private void printSpecs(ImmutableList<? extends Specification> specs) {
    for (Specification s : specs) {
      ++indentLevel; 
      nl();
      s.eval(this);
      --indentLevel;
      nl();
    }
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
    if (!typeArgs.isEmpty()) {
      say("<");
      printList(", ", typeArgs);
      say(">");
    }
    say("(");
    printList(", ", args);
    say(")");
    if (!results.isEmpty()) {
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
    say("ensures");
    if (!typeArgs.isEmpty()) {
      say("<");
      printList(", ", typeArgs);
      say(">");
    }
    say(" ");
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
    say("requires");
    if (!typeArgs.isEmpty()) {
      say("<");
      printList(", ", typeArgs);
      say(">");
    }
    say(" ");
    expr.eval(this);
    semi();
  }


  @Override
  public void see(
    TypeDecl typeDecl,
    ImmutableList<Attribute> attr,
    boolean finite,
    String name,
    ImmutableList<AtomId> typeArgs,
    Type type
  ) {
    say("type ");
    printList(" ", attr);
    switch (boogieVersion) {
      case TWO:
        if (finite) {
          say("finite");
          say(" ");
        }
        break;
    }
    say(name);
    // TODO: print space-separated typeArgs
    if (type != null) {
      say(" = ");
      type.eval(this);
    }
    semi();
  }

  @Override
  public void see(UnaryOp unaryOp, UnaryOp.Op op, Expr e) {
    say(unRep.get(op));
    e.eval(this);
  }

  @Override
  public void see(
      UserType userType,
      String name,
      ImmutableList<Type> typeArgs
  ) {
    say(name);
    // TODO: print space-separated typeArgs
  }

  @Override
  public void see(
    VariableDecl variableDecl, 
    ImmutableList<Attribute> attr,
    String name, 
    Type type, 
    ImmutableList<AtomId> typeVars,
    Expr where
  ) {
    if (skipVar==0) say("var ");
    printList(" ", attr);
    say(name);
    if (!typeVars.isEmpty()) {
      say("<");
      printList(", ", typeVars);
      say(">");
    }
    say(" : ");
    type.eval(this);
    if (where != null) {
      say(" ");
      say("where");
      say(" ");
      where.eval(this);
    }
    if (skipVar==0) semi();
  }
  
  @Override
  public void see(
      Attribute attribute, 
      String type, 
      ImmutableList<Expr> exprs
  ) {
    say("{");
    say(":"); say(type);
    say(" ");
    printList(" ", exprs);
    say("} ");
  }

  @Override public void see(
      GotoCmd gotoCmd, 
      ImmutableList<String> labels,
      ImmutableList<String> successors
  ) {
    for (String l : labels) {
      say(l);
      say(": ");
    }
    if (successors.isEmpty())
      say("return");
    else {
      say("goto ");
      for (int i = 0; i < successors.size(); ++i) {
        if (i != 0) say(", ");
        say(successors.get(i));
      }
    }
    semi();
  }

  @Override public void see(
      WhileCmd whileCmd, 
      ImmutableList<String> labels,
      Expr condition,
      ImmutableList<LoopInvariant> inv,
      Block body
  ) {
    assert false : "not implemented";
  }

}
