package freeboogie.vcgen;

import java.util.*;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

import freeboogie.ast.*;
import freeboogie.backend.*;

/**
 * Sends global axioms to the prover. These include Boogie axioms
 * and axioms for uniqueness of constants.
 * @param <T> the type of terms
 */
public class AxiomSender<T extends Term<T>> extends Transformer {
  private Prover<T> prover;
  private TermBuilder<T> term;
  private Set<T> axioms = Sets.newHashSet();
  private List<String> uniqConst = Lists.newArrayList();

  public void setProver(Prover<T> prover) {
    this.prover = prover;
    this.term = prover.getBuilder();
  }

  public void process(Program p) throws ProverException {
    axioms.clear();
    uniqConst.clear();
    p.eval(this);

    ImmutableList.Builder<T> uc = ImmutableList.builder();
    for (String cn : uniqConst)
      uc.add(term.mk("var", "term$$" + cn));
    axioms.add(term.mk("distinct", uc.build()));

    for (T t : axioms) prover.assume(t);
  }

  @Override
  public void see(
    Axiom axiom,
    ImmutableList<Attribute> attr,
    String name,
    ImmutableList<AtomId> typeArgs,
    Expr expr
  ) {
    T a = term.of(expr);
    axioms.add(a);
    a.collectAxioms(axioms);
  }

  @Override
  public void see(
    ConstDecl constDecl, 
    ImmutableList<Attribute> attr, 
    String id,
    Type type,
    boolean uniq
  ) {
    if (uniq) uniqConst.add(id);
  }
}
