package freeboogie.tc;

import java.util.*;

import com.google.common.collect.*;

import freeboogie.ast.*;

/** Desugars type synonyms by applying substitutions. */
public class TypeDesugarer extends Transformer {
  private List<FbError> errors = Lists.newArrayList();
  private SymbolTable st;
  private GlobalsCollector gc;

  public void symbolTable(SymbolTable st) { this.st = st; }
  public void globalsCollector(GlobalsCollector gc) { this.gc = gc; }
  public List<FbError> errors() { return Lists.newArrayList(errors); }

  @Override public Program process(Program program, TcInterface typechecker) 
  throws ErrorsFoundException {
    // Compute the symbol table.
    SymbolTableBuilder stb = new SymbolTableBuilder();
    program = stb.process(program, typechecker);
    st = stb.st();
    gc = stb.gc();

    // Desugar type synonyms.
    program = (Program) program.eval(this);
    if (!errors.isEmpty()) throw new ErrorsFoundException(errors);

    // Update the typechecker
    return typechecker.process(program);
  }

  /* Takes care of removing type synonyms from the AST. */
  @Override public Program eval(Program program) {
    errors.clear();

    ImmutableList.Builder<TypeDecl> typeDecl = ImmutableList.builder();
    for (TypeDecl td : program.types())
      if (td.type() == null) typeDecl.add(td);

    return Program.mk(
        program.fileName(),
        typeDecl.build(),
        AstUtils.evalListOfAxiom(program.axioms(), this),
        AstUtils.evalListOfVariableDecl(program.variables(), this),
        AstUtils.evalListOfConstDecl(program.constants(), this),
        AstUtils.evalListOfFunctionDecl(program.functions(), this),
        AstUtils.evalListOfProcedure(program.procedures(), this),
        AstUtils.evalListOfImplementation(program.implementations(), this),
        program.loc());
  }

  @Override public Type eval(UserType userType) {
    // Check if this is a type synonym.
    TypeDecl td = getTypeDeclaration(userType);
    if (td == null || td.type() == null) {
      // If not, then just process the children.
      return (Type) super.eval(userType);
    }

    // Check if a correct number of arguments is provided.
    if (userType.typeArgs().size() != td.typeArgs().size()) {
      errors.add(new FbError(
          FbError.Type.TYPE_ARGS_MISMATCH,
          userType,
          userType.typeArgs().size(),
          td,
          td.typeArgs().size()));
      return userType;
    }

    // Do one substitution.
    Map<Ast, Ast> toSubstitute = Maps.newHashMap();
    UnmodifiableIterator<Identifier> tv = td.typeArgs().iterator();
    UnmodifiableIterator<Type> ta = userType.typeArgs().iterator();
    while (tv.hasNext()) {
      Type et = ta.next();
      for (UserType ut : st.typeVars.usages(tv.next())) {
        toSubstitute.put(ut, et);
      }
    }
    Type result = (Type) td.type().eval(new Substitutor(toSubstitute)).clone();

    // Repeat.
    return (Type) result.eval(this);
  }

  private TypeDecl getTypeDeclaration(UserType userType) {
    return gc.typeDef(userType.name());
  }
}
