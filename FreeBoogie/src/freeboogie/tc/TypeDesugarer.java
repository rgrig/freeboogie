package freeboogie.tc;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.*;

import freeboogie.ast.*;

/** Desugars type synonyms by applying substitutions. */
public class TypeDesugarer extends Transformer {
  private Map<Identifier, Type> toSubstitute = Maps.newHashMap();
  private List<FbError> errors = Lists.newArrayList();
  private Set<UserType> seen = Sets.newHashSet();
  private SymbolTable st;

  /* Takes care of removing type synonyms from the AST. */
  @Override public Program eval(Program program) {
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

  // TODO(radugrigore): nicer error for cycles
  // TODO(radugrigore): make sure that toSubstitute doesn't need nested scopes.
  @Override public Type eval(UserType userType) {
    ImmutableList<Type> typeArgs = userType.typeArgs();

    // Check for cycles.
    if (seen.contains(userType)) {
      errors.add(new FbError(
          FbError.Type.TYPE_CYCLE, 
          userType, 
          userType.name()));
      return userType;
    }

    // Replace type variables by their real type.
    Identifier tv = st.typeVars.def(userType);
    if (tv != null) {
      if (!typeArgs.isEmpty()) {
        errors.add(new FbError(
            FbError.Type.TYPE_ARGS_MISMATCH, 
            userType, 
            userType.typeArgs().size(),
            tv.loc(),
            0));
      }
      return (Type) toSubstitute.get(tv).eval(this);
    }

    // Replace type synonyms by their real type.
    ImmutableList<Type> newTypeArgs = AstUtils.evalListOfType(typeArgs, this);
    TypeDecl td = st.types.def(userType);
    Type t = td.type();
    if (t != null) {
      UnmodifiableIterator<Identifier> formals = td.typeArgs().iterator();
      UnmodifiableIterator<Type> actuals = userType.typeArgs().iterator();
      while (formals.hasNext()) 
        toSubstitute.put(formals.next(), actuals.next());
      return (Type) t.eval(this);
    }

    // Otherwise, just keep the result of the recursive
    // processing of children.
    if (newTypeArgs != typeArgs)
      userType = UserType.mk(userType.name(), newTypeArgs, userType.loc());
    return userType;
  }
}
