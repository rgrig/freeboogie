package freeboogie.tc;

import java.util.*;

import com.google.common.collect.*;

import freeboogie.ast.*;

/** Desugars type synonyms by applying substitutions. */
public class TypeDesugarer extends Transformer {
  private List<FbError> errors;
  private SymbolTable st;

  /* The following two are used to detect and report cycles in
     type synonyms. */
  private Set<UserType> seenSet = Sets.newHashSet();
  private Deque<UserType> seenStack = new ArrayDeque<UserType>();

  /* Takes care of removing type synonyms from the AST. */
  @Override public Program eval(Program program) {
    seenSet.clear();
    seenStack.clear();
    errors = Lists.newArrayList();

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
    Type result = userType;

    // Check if this is a type synonym.
    TypeDecl td = getTypeDeclaration(userType);
    if (td.type() == null) {
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
      for (UserType ut : st.typeVars.usages(tv.next()))
        toSubstitute.put(ut, et);
    }
    result = (Type) td.type().eval(new Substitutor(toSubstitute));

    // Repeat.
    return (Type) result.eval(this);
  }

  // TODO(radugrigore): use the name of userType (so that things
  //   returned by Substitutor are processed correctly)
  private TypeDecl getTypeDeclaration(UserType userType) {
    return st.types.def(userType);
  }
}
