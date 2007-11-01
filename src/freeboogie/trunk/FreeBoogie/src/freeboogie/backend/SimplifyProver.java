package freeboogie.backend;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Deque;
import java.util.List;

import freeboogie.util.StackedHashMap;


/**
 * Used to interact with Simplify.
 *
 * @author rgrig 
 * @author reviewed by TODO
 */
public class SimplifyProver implements Prover {
  
  private Process prover;
  private List<String> cmd;
  
  private BufferedReader in;
  private PrintStream out;
  
  // a |null| is used to mark the beginning of an assumption frame
  private Deque<Term> assumptions;
  
  /**
   * Creates a new {@code SimplifyProver}. It also tries to start the prover. 
   * @param cmd the command to use to start the prover
   * @throws ProverException if the prover cannot be started
   */
  public SimplifyProver(String[] cmd) throws ProverException {
    this.cmd = Arrays.asList(cmd);
    assumptions = new ArrayDeque<Term>();
    assumptions.add(null);
    restartProver();
  }
  
  private void sendTerm(Term t) {
    assert false; // TODO
  }
  
  private void sendAssume(Term t) {
    out.print("(BG_PUSH ");
    sendTerm(t);
    out.print(")\n");
    out.flush();
  }
  
  private void checkIfDead() throws ProverException {
    try {
      int ev = prover.exitValue();
      throw new ProverException("Prover exit code: " + ev);
    } catch (IllegalThreadStateException e) {
      // the prover is still alive
    }
  }

  /* @see freeboogie.backend.Prover#assume(freeboogie.backend.Term) */
  public void assume(Term t) throws ProverException {
    sendAssume(t);
    assumptions.add(t);
    checkIfDead();
  }

  /* @see freeboogie.backend.Prover#getBuilder() */
  public TermBuilder getBuilder() {
    // TODO Auto-generated method stub
    return null;
  }

  /* @see freeboogie.backend.Prover#getDetailedAnswer() */
  public ProverAnswer getDetailedAnswer() {
    // TODO Auto-generated method stub
    return null;
  }

  /* @see freeboogie.backend.Prover#isSat(freeboogie.backend.Term) */
  public boolean isSat(Term t) throws ProverException {
    // TODO Auto-generated method stub
    return false;
  }

  /* @see freeboogie.backend.Prover#pop() */
  public void pop() throws ProverException {
    while (assumptions.getLast() != null) retract();
    assumptions.removeLast();
  }

  /* @see freeboogie.backend.Prover#push() */
  public void push() {
    assumptions.push(null);
  }

  /* @see freeboogie.backend.Prover#restartProver() */
  public void restartProver() throws ProverException {
    ProcessBuilder pb = new ProcessBuilder(this.cmd);
    try {
      prover = pb.start();
      in = new BufferedReader(new InputStreamReader(prover.getInputStream()));
      out = new PrintStream(prover.getOutputStream());
      out.println("(PROMPT_ON)"); // make sure prompt is ON
      out.flush();
    } catch (Exception e) {
      throw new ProverException("Cannot start prover.");
    }
  }

  /* @see freeboogie.backend.Prover#retract() */
  public void retract() {
    Term last;
    do last = assumptions.getLast(); while (last == null);
    out.print("(BG_POP)");
    out.flush();
  }
  
}