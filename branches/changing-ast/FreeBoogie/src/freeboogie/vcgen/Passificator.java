package freeboogie.vcgen;

import java.io.PrintWriter;
import java.util.*;
import java.util.Map.Entry;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;
import genericutils.Err;
import genericutils.Id;
import genericutils.SimpleGraph;

import freeboogie.ast.*;
import freeboogie.astutil.PrettyPrinter;
import freeboogie.tc.TtspRecognizer;
import freeboogie.tc.TcInterface;
import freeboogie.tc.TypeUtils;

/**
 * Passify option.
 * Implements the algorithm found in the paper 
 * Avoiding Exponential Explosion: Generating Compact Verification Conditions
 * C. Flanagan and J. B. Saxe
 * 
 * 
 * @author J. Charles (julien.charles@gmail.com)
 */
public class Passificator extends ABasicPassifier {
  /** the main global environment. */
  private Environment fEnv;

  /**
   * Process the AST, and returns the modified version.
   * @param ast the ast to look at.
   * @return a valid modified ast
   */
  public Program process(final Program ast, final TcInterface tc) {
    this.tc = tc;
    fEnv = new Environment(ast.fileName());
    for (VariableDecl vd : ast.variables()) fEnv.addGlobal(vd);
    Program passifiedAst = (Program) ast.eval(this);
    
    if (false) { // TODO log-categ
      System.out.print(fEnv.globalToString());
    }
    passifiedAst = addVariableDeclarations(passifiedAst);
    return TypeUtils.internalTypecheck(passifiedAst, tc);
  }
 
  /**
   * Handles one implementation.
   */
  @Override
  public Implementation eval(
    Implementation implementation,
    ImmutableList<Attribute> attr,
    Signature sig,
    Body oldBody
  ) {
    SimpleGraph<Block> currentFG = tc.flowGraph(implementation);
    TtspRecognizer<Block> recog = new TtspRecognizer<Block>(currentFG, oldBody.blocks().get(0));
    Body body = oldBody;
    if (!recog.check()) {
      Err.warning(this + " " + implementation.loc() + ": Implementation " + 
        sig.name() + " is not a series-parallel graph. I'm not passifying it.");
    } else if (currentFG.hasCycle()) {
      Err.warning(this + " " + implementation.loc() + ": Implementation " + 
        sig.name() + " has cycles. I'm not passifying it.");
    } else {
      if (false) { // TODO log-categ
        System.out.println("process " + sig.name());
      }
      BodyPassifier bp = BodyPassifier.passify(
        tc,
        fEnv, 
        oldBody,
        sig);
      sig = Signature.mk(
        sig.name(), 
        sig.typeArgs(), 
        sig.args(),
        bp.getResult(),
        sig.loc());
      body = bp.getBody();
      fEnv.updateGlobalWith(bp.getEnvironment());
    }

    return Implementation.mk(attr, sig, body);
  }

  
  
  /**
   * Adds to the AST the variable declarations for the variables
   * that were added by the algorithm.
   * @param ast the AST to transform
   * @return the AST with the added declarations
   */
  private Program addVariableDeclarations(Program ast) {
    ImmutableList.Builder<VariableDecl> newVariables = ImmutableList.builder();
    newVariables.addAll(ast.variables());
    for (Map.Entry<VariableDecl, Integer> e : fEnv.getGlobalSet()) {
      for (int i = 1; i <= e.getValue(); ++i)
        newVariables.add(mkDecl(e.getKey(), i));
    }
    return Program.mk(
        ast.fileName(),
        ast.types(),
        ast.axioms(),
        newVariables.build(),
        ast.constants(),
        ast.functions(),
        ast.procedures(),
        ast.implementations(),
        ast.loc());
  }

  
  /**
   * 
   * TODO: description.
   *
   * @author J. Charles (julien.charles@inria.fr)
   * @author reviewed by TODO
   */
  private static class BodyPassifier extends ABasicPassifier {
    /** the list of local variables declarations. */
    private ImmutableList.Builder<VariableDecl> newLocals;
    private ImmutableList.Builder<Block> newBlocks;
    /** the current counter associated with each local variable. */
    private final Environment freshEnv;

    private final Map<Block, Environment> startBlockStatus = 
        Maps.newHashMap();
    private final Map<Block, Environment> endBlockStatus = 
        Maps.newHashMap();
    private final ImmutableList<VariableDecl> fResults;
    private SimpleGraph<Block> fFlowGraph;
    
    private Body fBody;
    private ImmutableList<VariableDecl> fNewResults;
    /**
     * Builds a body passifier.
     * @param typeChecker  
     * @param bIsVerbose
     * @param globalEnv 
     * @param sig */
    public BodyPassifier(
      final TcInterface typeChecker, 
      Environment globalEnv,
      final Signature sig
    ) {
      this.tc = typeChecker;
      freshEnv = new Environment(sig.loc() + " " + sig.name());
      fResults = sig.results();
      freshEnv.putAll(globalEnv);
      for (VariableDecl vd : sig.args()) freshEnv.put(vd, 0);
    }
    
    public Environment getEnvironment() {
      return freshEnv;
    }

    public Body getBody() {
      return fBody;
    }

    public static BodyPassifier passify(
      TcInterface fTypeChecker,
      Environment globalEnv, 
      Body body,
      Signature sig
    ) {
      BodyPassifier bp = new BodyPassifier(fTypeChecker, globalEnv, sig);
      body.eval(bp);
      return bp;
    }

    private void computeDeclarations() {
      fNewResults = newResults(fResults);
      newLocals();
    }
    
    private void newLocals() {
      for (Entry<VariableDecl, Integer> decl: freshEnv.getLocalSet()) {
        int last = decl.getValue();
        VariableDecl old = decl.getKey();
        for (int i = 1; i <= last; ++i) {
          newLocals.add(mkDecl(old, i));
        }
      }
    }

    private ImmutableList<VariableDecl> newResults(
        ImmutableList<VariableDecl> old
    ) {
      ImmutableList.Builder<VariableDecl> builder = ImmutableList.builder();
      for (VariableDecl r : old) {
        int last = freshEnv.get(r);
        freshEnv.remove(r);
        for (int i = 0; i < last; ++i) builder.add(mkDecl(r, i));
      }
      return builder.build();
    }
    
    @Override
    public Body eval(
        final Body body, 
        ImmutableList<VariableDecl> vars, 
        ImmutableList<Block> blocks
    ) {
      // process out parameters
      newLocals = ImmutableList.builder();
      newLocals.addAll(vars);
      for (VariableDecl vd : vars) freshEnv.put(vd, 0);
      
      fFlowGraph = tc.flowGraph(body);
      newBlocks = ImmutableList.builder();
      for (Block b : fFlowGraph.nodesInTopologicalOrder())
        newBlocks.add((Block) b.eval(this));
      
      if (false) { // TODO log-categ
        System.out.print(freshEnv.localToString());
      }
      computeDeclarations();
      return fBody = Body.mk(newLocals.build(), newBlocks.build());
    }
   
    @Override public Block eval(
        Block block, 
        String name,
        Command cmd,
        ImmutableList<AtomId> succ
    ) {
      Set<Block> blist = fFlowGraph.from(block);
      Environment env = merge(blist);
      if (env == null) {
        env = freshEnv.clone();
      }
      
      startBlockStatus.put(block, env.clone()); 

      Command newCmd = AstUtils.eval(cmd, new CommandEvaluator(tc, env));
      endBlockStatus.put(block, env);  
      
      ImmutableList<AtomId> newSucc = succ;
      
      // now we see if we have to add a command to be more proper :P
      Set<Block> succList = fFlowGraph.to(block);
      if (succList.size() == 1) { // TODO(rgrig): is this ok?
        Block next = succList.iterator().next();
        Environment nextEnv = startBlockStatus.get(next);
        for (Entry<VariableDecl, Integer> entry: nextEnv.getAllSet()) {
          VariableDecl decl = entry.getKey();
          int currIdx = env.get(decl);
          int oldIdx = entry.getValue();
          if (oldIdx != currIdx) {
            // we have to add an assume
            AtomId newVar = mkVar(decl, oldIdx);
            AtomId oldVar = mkVar(decl, currIdx);
            Command assumeCmd = mkAssumeEQ(newVar, oldVar);
            String nodeName = Id.get(name);
            newBlocks.add(Block.mk(nodeName, assumeCmd, newSucc, block.loc()));
            newSucc = AstUtils.ids(nodeName);
          }
        }
      }
      freshEnv.updateWith(env);
      return Block.mk(name, newCmd, newSucc, block.loc());
    }

    /**
     * Merge a list of environments associated with blocks.
     * @param blist
     * @return the merged environment
     */
    // TODO(rgrig): this function looks very suspicious
    private Environment merge(Set<Block> blist) {
      if (blist.size() == 0) {
        return null;
      }
      
      Environment res = new Environment(freshEnv.getLoc());
      res.putAll(endBlockStatus.get(blist.iterator().next()));
      
      if (blist.size() == 1) {
        return res;
      }
      
      for (Entry<VariableDecl, Integer> entry: res.getAllSet()) {
        VariableDecl decl = entry.getKey();
        int currInc = entry.getValue();
        boolean change = false;
        for (Block b: blist) {
          Integer incarnation = endBlockStatus.get(b).get(decl);
          int inc = incarnation == null ? 0 : incarnation;
          if (currInc!= inc) {
            if (inc > currInc) {
              currInc= incarnation;
            }
            change = true;
          }
        }
        if (change) {
          int newvar = freshEnv.get(decl) + 1;
          res.put(decl, newvar);
          freshEnv.put(decl, newvar);
        }
      }
      return res;
    }

    
    /**
     * Returns the new variable representing the result that
     * has been computed by the algorithm.
     * @return the corresponding result variable
     */
    public ImmutableList<VariableDecl> getResult() {
      return fNewResults;
    }
    
    private class CommandEvaluator extends ABasicPassifier {
      Environment env;
      int belowOld = 0;
      
      public CommandEvaluator(TcInterface tc, Environment env) {
        this.tc = tc;
        this.env = env;
      }

      /**
       * Returns a fresh identifier out of an old one.
       * @param var the old id
       * @return an id which was not used before.
       */
      public AtomId fresh(AtomId var) {
        VariableDecl decl = getDeclaration(var);
        Integer i = freshEnv.get(decl);
        int curr = i == null? 0 : i;
        curr++;
        env.put(decl, curr);
        freshEnv.put(decl, curr);
        return mkVar(var, curr);
      }
      
      
      @Override
      public Expr eval(AtomOld atomOld, Expr e) {
        ++belowOld;
        e = (Expr)e.eval(this);
        --belowOld;
        return e;
      }
      
      @Override
      public AssertAssumeCmd eval(final AssignmentCmd assignmentCmd, 
                                  final AtomId var, final Expr rhs) {
        AssertAssumeCmd result = null;
        Expr value = (Expr) rhs.eval(this);
        result = mkAssumeEQ(fresh(var), value);
        return result;
      }


      /**
       * Returns a fresh identifier out of an old one.
       * @param var the old id
       * @return an id which was not used before.
       */
      public AtomId get(AtomId var) {
        VariableDecl decl = getDeclaration(var);
        if (decl == null) {
          // Symbol here!
          return mkVar(var, 0);
        }
        int i = env.get(decl);
        if (belowOld > 0) {
          i = 0;
        }
        return mkVar(var, i);
      }
      
      @Override
      public AtomId eval(AtomId atomId, String id, ImmutableList<Type> types) {
        return get(atomId);
      }
    }
  }



}
