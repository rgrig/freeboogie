package freeboogie.vcgen;

import java.util.ArrayList;

import com.google.common.collect.ImmutableList;

import freeboogie.ast.*;
import freeboogie.backend.Sort;
import freeboogie.backend.TermBuilder;
import freeboogie.tc.SymbolTable;
import freeboogie.tc.TcInterface;
import freeboogie.tc.TypeUtils;

/**
 * Registers symbols corresponding to the functions in Boogie.
 *
 * All function symbols are prefixed by "funX_" where X is either
 * I, B, or T, depending on whether the return type is int, bool,
 * or something else. If the return type is a type variable
 * then the name of the function is registered with all three
 * prefixes.
 */
public class FunctionRegisterer extends Transformer {
  private static Sort[] sortArray = new Sort[0];

  private TermBuilder builder;
  private ArrayList<Sort> argSorts = new ArrayList<Sort>();
  private SymbolTable st;

  public void setBuilder(TermBuilder builder) {
    this.builder = builder;
  }

  @Override
  public Program process(Program ast, TcInterface tc) {
    st = tc.st();
    ast.eval(this);
    return ast;
  }

  @Override
  public void see(
    FunctionDecl function,
    ImmutableList<Attribute> attr,
    Signature sig
  ) {
    argSorts.clear();
    getArgSorts(sig.args());
    Sort[] asa = argSorts.toArray(sortArray);
    if (sig.results().size() == 1) {
      Type t = sig.results().get(0).type();
      if (TypeUtils.isInt(t) || isTypeVar(t))
        builder.def("funI_" + sig.name(), asa, Sort.INT);
      if (TypeUtils.isBool(t) || isTypeVar(t))
        builder.def("funB_" + sig.name(), asa, Sort.BOOL);
    } 
    builder.def("funT_" + sig.name(), asa, Sort.TERM);
  }

  // === helpers ===
  private void getArgSorts(ImmutableList<VariableDecl> args) {
    for (VariableDecl vd : args) argSorts.add(Sort.of(vd.type()));
  }

  private boolean isTypeVar(Type t) {
    if (!(t instanceof UserType)) return false;
    UserType ut = (UserType) t;
    return st.typeVars.def(ut) != null;
  }
}
