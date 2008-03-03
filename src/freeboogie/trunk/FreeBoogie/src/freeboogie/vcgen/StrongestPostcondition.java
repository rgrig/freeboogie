package freeboogie.vcgen;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.logging.Logger;

import freeboogie.ast.*;
import freeboogie.backend.Prover;
import freeboogie.backend.Term;
import freeboogie.backend.TermBuilder;
import freeboogie.tc.*;

/**
 * Computes strongest postcondition for one {@code
 * Implementation}.
 *
 * This class receives a flow graph of commands ({@code
 * SimpleGraph<AssertAssumeCmd>}) and computes preconditions and
 * postconditions for all nodes, verification conditions for
 * individual assertions, and a verification condition for all
 * assertion.
 *
 * The graph must be acyclic.
 *
 * (The input can be obtained as follows: (a) parse BPL, (b) add
 * procedure specs to the body as assumes and assert, (c) build a
 * flow graph, (d) make that reducible, (e) eliminate loops, and
 * (f) passivate.)
 *
 * The formulas are built using a {@code TermBuilder} that
 * is handed to us by the user. That {@code TermBuilder}
 * must know about the terms "const_pred", "and", "or", and "implies".
 *
 * TODO Explain which nodes are considered initial and which are
 * cosidered final.
 *
 * TODO Give some guides in a document somewhere how to name terms.
 *
 * Each command is attached a precondition and a postcondition
 * according to the following definitions:
 * <pre>
 * pre(n) = TRUE                      if n is an entry point
 * pre(n) = OR_{m BEFORE n} post(m)   otherwise
 * post(n) = pre(n) AND term(expr(n)) if n is an assume
 * post(n) = pre(n)                   if n is an assert
 * </pre>
 *
 * The user can say (by calling {@code assertsAsAssumes}) that
 * asserts should be treated as they are also assumes (followed
 * by...)
 *
 * The verification condition is then computed as:
 * <pre>
 * VC = AND_{n is assert} (pre(n) IMPLIES term(expr(n)))
 * </pre>
 *
 * @author rgrig
 * @author reviewed by TODO
 */
public class StrongestPostcondition {

  // used mainly for debugging
  static private final Logger log = Logger.getLogger("freeboogie.vcgen");

  // builds terms for a specific theorem prover
  private TermBuilder term;

  // the control flow graph currently being processed
  private SimpleGraph<AssertAssumeCmd> flow;

  // treat assert _also_ as assumes
  private boolean aaa;
  
  // the preconditions of each command
  private HashMap<AssertAssumeCmd, Term> preCache;

  // the postconditions of each command
  private HashMap<AssertAssumeCmd, Term> postCache;

  public StrongestPostcondition(TermBuilder term) {
    this.term = term;
  }
  
  /**
   * Sets the flow graph to be processed by the next calls to
   * {@code pre}, {@code post}, and {@code vc}. This class
   * assumes that {@code flow} won't be changed.
   * (TODO: add a freeze method and a frozen property to
   * {@code SimpleGraph}).
   */
  public void setFlowGraph(SimpleGraph<AssertAssumeCmd> flow) {
    log.info("prepare to compute sp on a new flow graph");
    this.flow = flow;
    preCache = new HashMap<AssertAssumeCmd, Term>();
    postCache = new HashMap<AssertAssumeCmd, Term>();
    // TODO check for cycles and abort if any
  }

  /**
   * Controls whether we should generate bigger VCs by trying to
   * guide the theorem prover by giving assertions as lemmas.
   * (That statement is informal, not precise.) I won't crash
   * if you change your mind in the middle but I don't promise
   * anything about the terms I produce, other than they should
   * be correct, strictly speaking.
   */
  public void setAssertAsAssume(boolean aaa) {
    this.aaa = aaa;
  }

  /**
   * Returns the precondition of {@code cmd}, which must be in
   * the last set flow graph.
   */
  public Term pre(AssertAssumeCmd cmd) {
    Term r = preCache.get(cmd);
    if (r != null) return r;
    ArrayList<Term> toOr = new ArrayList<Term>();
    for (AssertAssumeCmd p : flow.from(cmd)) 
      toOr.add(post(p));
    if (toOr.isEmpty())
      // assume it's initial 
      r = term.mk("const_pred", Boolean.valueOf(true));
    else
      r = term.mk("or", toOr.toArray(new Term[0]));
    preCache.put(cmd, r);
    return r;
  }

  public Term post(AssertAssumeCmd cmd) {
    Term r = postCache.get(cmd);
    if (r != null) return r;
    r = pre(cmd);
    if (aaa || cmd.getType() == AssertAssumeCmd.CmdType.ASSUME)
      r = term.mk("and", r, term.of(cmd.getExpr()));
    postCache.put(cmd, r);
    return r;
  }

  /**
   * Returns the verification condition for a particular command.
   * If {@code cmd} is an assume then I return TRUE.
   */
  public Term vc(AssertAssumeCmd cmd) {
    switch (cmd.getType()) {
    case ASSUME:
      return term.mk("const_pred", Boolean.valueOf(true));
    case ASSERT:
      return term.mk("implies", pre(cmd), term.of(cmd.getExpr()));
    }
    assert false;
    return null;
  }

  /**
   * Returns a verification condition for the whole flow graph.
   */
  public Term vc() {
    assert false;
    return null;
    // TODO
  }

  /**
   * Returns the postcondition for {@code impl}.
   */
  public Term getVc(Implementation impl) {
    Block entry = impl.getBody().getBlocks();
    assert false;
    // TODO Continue here
    return null;
  }

}