package freeboogie.tc;

import java.util.*;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.UnmodifiableIterator;

import freeboogie.ast.*;

/**
 * Checks whether the implementations' signatures correspond
 * to the procedure signatures. It also connects in/out {@code
 * VariableDecl} arguments of the implementation with the one in
 * the procedure. (This link is needed later when verifying that
 * the implementation satisfies the spec that accompanies the
 * procedure.) It produces errors if an implementation does not
 * have a corresponding procedure or if there is a type mismatch
 * in the signature.
 *
 * @author rgrig 
 */
@SuppressWarnings("unused") // unused parameters
public class ImplementationChecker extends Transformer {
  private List<FbError> errors;
  private GlobalsCollector gc;
  
  // connects implementations to procedures
  private UsageToDefMap<Implementation, Procedure> implProc;
  
  // connects implementation parameters to procedure parameters
  private UsageToDefMap<VariableDecl, VariableDecl> paramMap;
  
  // === public interface ===
  
  /**
   * Processes the implementations in {@code ast} assuming that {@code p}
   * maps procedure names to their AST nodes. ({@code GlobalsCollector} provides
   * such a mapping.)
   * @param ast the AST to check
   * @param g the globals collector that can resolve procedure names 
   * @return the detected problems 
   */
  public List<FbError> process(Program ast, GlobalsCollector g) {
    errors = Lists.newArrayList();
    gc = g;
    implProc = new UsageToDefMap<Implementation, Procedure>();
    paramMap = new UsageToDefMap<VariableDecl, VariableDecl>();
    ast.eval(this);
    return errors;
  }
  
  /**
   * Returns the map linking procedures to their usages.
   * @return the map linking procedures to their usages
   */
  public UsageToDefMap<Implementation, Procedure> implProc() {
    return implProc;
  }
  
  /**
   * Returns the map of implementation in/out parameters to the map
   * of procedure in/out parameters.
   * @return the link between implementation and procedure parameters
   */
  public UsageToDefMap<VariableDecl, VariableDecl> paramMap() {
    return paramMap;
  }
  
  // === helpers ==
  
  // compares the types in |a| and |b| and reports mismatches
  private void compare(
      ImmutableList<VariableDecl> a, 
      ImmutableList<VariableDecl> b
  ) {
    if (a.size() != b.size()) {
      Ast loc = null;
      if (!b.isEmpty()) loc = b.get(0);
      if (!a.isEmpty()) loc = a.get(0);
      errors.add(new FbError(FbError.Type.IP_CNT_MISMATCH, loc));
      return;
    }

    UnmodifiableIterator<VariableDecl> ia = a.iterator();
    UnmodifiableIterator<VariableDecl> ib = b.iterator();
    while (ia.hasNext()) {
      VariableDecl va = ia.next();
      VariableDecl vb = ib.next();
      if (!TypeUtils.eq(TypeUtils.stripDep(va.type()), TypeUtils.stripDep(vb.type()))) {
        errors.add(new FbError(FbError.Type.EXACT_TYPE, va,
              TypeUtils.typeToString(vb.type())));
        return;
      }
      paramMap.put(va, vb);
    }
  }
  
  // report an error if there is any dependent type
  private void depCheck(ImmutableList<VariableDecl> a) {
    for (VariableDecl vd : a) {
      if (TypeUtils.hasDep(vd.type()))
        errors.add(new FbError(FbError.Type.DEP_IMPL_SIG, vd));
    }
  }
  
  // === visiting implementations ===

  @Override
  public void see(
    Implementation implementation,
    ImmutableList<Attribute> attr,
    Signature sig,
    Body body
  ) {
    String name = sig.name();
    Procedure p = gc.procDef(name);
    if (p == null) {
      errors.add(new FbError(FbError.Type.PROC_MISSING, implementation));
      return;
    }
    
    implProc.put(implementation, p);
    
    Signature psig = p.sig();
    compare(sig.args(), psig.args());
    compare(sig.results(), psig.results());
    
    depCheck(sig.args());
    depCheck(sig.results());
  }
}