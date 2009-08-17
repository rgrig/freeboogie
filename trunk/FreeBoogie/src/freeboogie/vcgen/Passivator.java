package freeboogie.vcgen;

import java.io.PrintWriter;
import java.util.*;
import java.util.logging.Logger;

import com.google.common.collect.*;
import genericutils.*;

import freeboogie.ast.*;
import freeboogie.astutil.PrettyPrinter;
import freeboogie.tc.*;
import freeboogie.vcgen.ABasicPassifier.Environment;

/**
 * Gets rid of assignments and "old" expressions by introducing 
 * new variables. We assume that
 *   (1) specs are desugared,
 *   (2) calls are desugared,
 *   (3) havocs are desugared,
 *   (4) the flowgraphs are computed and have no cycles.
 *
 * Each variable X is transformed into a sequence of variables
 * X, X_1, X_2, ... Each command has a read index r and a write
 * index w (for each variable), meaning that reads from X will be
 * replaced by reads from X_r and a write to X is replaced by a
 * write to X_w.
 *
 * We have:
 *   r(n) = max_{m BEFORE n} w(m)
 *   w(n) = 1 + r(n)   if n writes to X
 *   w(n) = r(n)       otherwise
 *
 * Copy operations (assumes) need to be inserted when the value
 * written by a node is not the same as the one read by one of
 * its successors (according the the scheme above).
 *
 * The "old()" is simply stripped.
 *
 * This algorithm minimizes the number of variables (think
 * coloring of comparison graphs) but not the number of copy
 * operations.
 *
 * TODO Introduce new variable declarations
 * TODO Change the out parameters of implementations to refer to the last version
 *
 * @author rgrig
 */
public class Passivator extends Transformer {
  // used mainly for debugging
  private static final Logger log = Logger.getLogger("freeboogie.vcgen");

  private HashMap<VariableDecl, HashMap<Block, Integer>> readIdx;
  private HashMap<VariableDecl, HashMap<Block, Integer>> writeIdx;
  private HashMap<VariableDecl, Integer> newVarsCnt;
  private HashMap<VariableDecl, Integer> toReport;
  private HashMap<Command, HashSet<VariableDecl>> commandWs;
  private List<Block> extraBlocks;
  private ReadWriteSetFinder rwsf;

  private VariableDecl currentVar;
  private HashMap<Block, Integer> currentReadIdxCache;
  private HashMap<Block, Integer> currentWriteIdxCache;
  private SimpleGraph<Block> currentFG;
  private Block currentBlock;
  private HashSet<VariableDecl> allWritten; // by the current implementation
  private ImmutableList.Builder<VariableDecl> newLocals;

  private int belowOld;
  private boolean inResults;

  // === transformers ===

  // visits ONLY implementations and then adds new globals
  @Override public Program eval(
      Program program,
      String fileName,
      ImmutableList<TypeDecl> types,
      ImmutableList<Axiom> axioms,
      ImmutableList<VariableDecl> variables,
      ImmutableList<ConstDecl> constants, 
      ImmutableList<FunctionDecl> functions,
      ImmutableList<Procedure> procedures,
      ImmutableList<Implementation> implementations
  ) {
    readIdx = Maps.newHashMap();
    writeIdx = Maps.newHashMap();
    newVarsCnt = Maps.newHashMap();
    toReport = Maps.newHashMap();
    commandWs = Maps.newHashMap();
    extraBlocks = Lists.newArrayList();
    rwsf = new ReadWriteSetFinder(tc.st());
    implementations = AstUtils.evalListOfImplementation(implementations, this);
    if (!newVarsCnt.isEmpty()) {
      ImmutableList.Builder<VariableDecl> newVariables = 
          ImmutableList.builder();
      newVariables.addAll(variables);
      for (Map.Entry<VariableDecl, Integer> e : newVarsCnt.entrySet()) {
        for (int i = 1; i <= e.getValue(); ++i) {
          newVariables.add(VariableDecl.mk(
              ImmutableList.<Attribute>of(),
              name(e.getKey().name(), i),
              TypeUtils.stripDep(e.getKey().type()).clone(), 
              AstUtils.cloneListOfAtomId(e.getKey().typeArgs())));
        }
      }
      variables = newVariables.build();
    }
    return Program.mk(
        fileName,
        types,
        axioms,
        variables,
        constants,
        functions,
        procedures,
        implementations,
        program.loc());
  }

  @Override
  public Implementation eval(
      Implementation implementation,
      ImmutableList<Attribute> attr, 
      Signature sig,
      Body body
  ) {
    currentFG = tc.flowGraph(implementation);
    if (currentFG.hasCycle()) {
      Err.warning("" + implementation.loc() + ": Implementation " + 
        sig.name() + " has cycles. I'm not passivating it.");
      return implementation;
    }
    
    // collect all variables that are assigned to
    Pair<CSeq<VariableDecl>, CSeq<VariableDecl>> rwIds = 
        implementation.eval(rwsf);
    allWritten = Sets.newLinkedHashSet();
    for (VariableDecl vd : rwIds.second) allWritten.add(vd);

    // figure out read and write indexes
    for (VariableDecl vd : allWritten) {
      currentVar = vd;
      currentReadIdxCache = Maps.newLinkedHashMap();
      currentWriteIdxCache = Maps.newLinkedHashMap();
      readIdx.put(vd, currentReadIdxCache);
      writeIdx.put(vd, currentWriteIdxCache);
      currentFG.iterNode(new Closure<Block>() {
        @Override public void go(Block b) {
          compReadIdx(b); compWriteIdx(b);
        }
      });
    }

    // transform the body and the out parameters
    belowOld = 0;
    newLocals = ImmutableList.builder();
    body = (Body) body.eval(this); // adds to newLocals
    sig = (Signature) sig.eval(this); // adds to newLocals
    newLocals.addAll(body.vars());
    body = Body.mk(newLocals.build(), body.blocks(), body.loc());
    return Implementation.mk(attr, sig, body);
  }

  @Override public Signature eval(
      Signature signature,
      String name,
      ImmutableList<AtomId> typeArgs,
      ImmutableList<VariableDecl> args,
      ImmutableList<VariableDecl> results
  ) {
    AstUtils.evalListOfVariableDecl(args, this);
    assert !inResults : "There shouldn't be nesting here.";
    inResults = true;
    results = AstUtils.evalListOfVariableDecl(results, this);
    inResults = false;
    return Signature.mk(name, typeArgs, args, results);
  }

  @Override public Body eval(
      Body body,
      ImmutableList<VariableDecl> vars,
      ImmutableList<Block> blocks
  ) {
    AstUtils.evalListOfVariableDecl(vars, this);
    ImmutableList.Builder<Block> newBlocks = ImmutableList.builder();
    for (Block b : blocks) {
      extraBlocks.clear();
      newBlocks.add((Block) b.eval(this)).addAll(extraBlocks);
    }
    // NOTE: newLocals are added later by eval(Implementation...)
    return Body.mk(vars, newBlocks.build(), body.loc());
  }


  // === workers ===

  private int compReadIdx(Block b) {
    if (currentReadIdxCache.containsKey(b))
      return currentReadIdxCache.get(b);
    int ri = 0;
    for (Block pre : currentFG.from(b))
      ri = Math.max(ri, compWriteIdx(pre));
    currentReadIdxCache.put(b, ri);
    return ri;
  }

  private int compWriteIdx(Block b) {
    if (currentWriteIdxCache.containsKey(b))
      return currentWriteIdxCache.get(b);
    int wi = compReadIdx(b);
    if (b.cmd() != null) {
      HashSet<VariableDecl> ws = commandWs.get(b.cmd());
      if (ws == null) {
        ws = Sets.newLinkedHashSet();
        for (VariableDecl vd : rwsf.get(b.cmd()).second) ws.add(vd);
        commandWs.put(b.cmd(), ws);
      }
      if (ws.contains(currentVar)) ++wi;
    }
    currentWriteIdxCache.put(b, wi);
    int owi = newVarsCnt.containsKey(currentVar) ? newVarsCnt.get(currentVar) : 0;
    newVarsCnt.put(currentVar, Math.max(owi, wi));
    return wi;
  }


  // === visitors ===
  @Override
  public Block eval(
      Block block, 
      String name, 
      Command cmd, 
      ImmutableList<AtomId> succ
  ) {
    currentBlock = block;
    // change variable occurrences in the command of this block
    Command newCmd = AstUtils.eval(cmd, this);

    /* Compute the successors, perhaps introducing extra blocks for
     * copy operations. */
    boolean changedSucc = false;
    ImmutableList.Builder<AtomId> newSucc = ImmutableList.builder();
    for (Block s : currentFG.to(block)) {
      String nextLabel, currentLabel;
      nextLabel = s.name();
      for (VariableDecl v : allWritten) {
        int ri = readIdx.get(v).get(s);
        int wi = writeIdx.get(v).get(block);
        if (ri == wi) continue;
        changedSucc = true;
        extraBlocks.add(Block.mk(
            currentLabel = Id.get("copyBlock"),
            AssertAssumeCmd.mk(
              AssertAssumeCmd.CmdType.ASSUME,
              ImmutableList.<AtomId>of(),
              BinaryOp.mk(
                BinaryOp.Op.EQ,
                AstUtils.mkId(name(v.name(), ri)),
                AstUtils.mkId(name(v.name(), wi)))),
            AstUtils.ids(nextLabel),
            block.loc()));
        nextLabel = currentLabel;
      }
      newSucc.add(AtomId.mk(nextLabel, ImmutableList.<Type>of(), block.loc()));
    }
    currentBlock = null;

    if (newCmd != cmd || changedSucc)
      block = Block.mk(name, newCmd, newSucc.build(), block.loc());
    return block;
  }

  // Note the return type
  @Override public AssertAssumeCmd eval(
      AssignmentCmd assignmentCmd, 
      AtomId lhs, 
      Expr rhs
  ) {
    AssertAssumeCmd result = null;
    Expr value = (Expr)rhs.eval(this);
    VariableDecl vd = (VariableDecl)tc.st().ids.def(lhs);
    return AssertAssumeCmd.mk(
        AssertAssumeCmd.CmdType.ASSUME, 
        ImmutableList.<AtomId>of(),
        BinaryOp.mk(BinaryOp.Op.EQ,
          AtomId.mk(
            name(lhs.id(), getIdx(writeIdx, vd)),
            lhs.types(), 
            lhs.loc()),
          value),
        assignmentCmd.loc());
  }

  @Override
  public Expr eval(AtomOld atomOld, Expr e) {
    ++belowOld;
    e = (Expr)e.eval(this);
    --belowOld;
    return e;
  }

  @Override
  public AtomId eval(AtomId atomId, String id, ImmutableList<Type> types) {
    if (currentBlock == null) return atomId;
    IdDecl d = tc.st().ids.def(atomId);
    if (!(d instanceof VariableDecl)) return atomId;
    VariableDecl vd = (VariableDecl) d;
    int idx = getIdx(readIdx, vd);
    if (idx == 0) return atomId;
    return AtomId.mk(name(id, idx), types, atomId.loc());
  }

  @Override
  public VariableDecl eval(
      VariableDecl variableDecl,
      ImmutableList<Attribute> attr,
      String name,
      Type type,
      ImmutableList<AtomId> typeArgs
  ) {
    Integer last = newVarsCnt.get(variableDecl);
    if (last == null) last = 0;
    newVarsCnt.remove(variableDecl);
    if (inResults) {
      variableDecl = VariableDecl.mk(
          ImmutableList.<Attribute>of(),
          name(name, last),
          type,
          typeArgs,
          variableDecl.loc());
    }
    int start = 1;
    if (inResults) {
      --last;
      --start;
    }
    for (int i = start; i <= last; ++i) {
      newLocals.add(VariableDecl.mk(
          ImmutableList.<Attribute>of(),
          name(name, i),
          TypeUtils.stripDep(type).clone(), 
          AstUtils.cloneListOfAtomId(typeArgs)));
    }
    return variableDecl;
  }

  // === helpers ===
  private int getIdx(
      HashMap<VariableDecl, 
      HashMap<Block, Integer> > cache, 
      VariableDecl vd
  ) {
    Map<Block, Integer> m = cache.get(vd);
    if (m == null || belowOld > 0 || currentBlock == null) 
      return 0; // this variable is never written to
    Integer idx = m.get(currentBlock);
    return idx == null? 0 : idx;
  }

  private String name(String prefix, int count) {
    if (count == 0) return prefix;
    return prefix + "$$" + count;
  }
}
