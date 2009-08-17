// vim:ft=java:
grammar Fb;

@header {
  package freeboogie.parser; 

  import java.math.BigInteger;

  import com.google.common.collect.ImmutableList;
  import com.google.common.collect.Lists;
  import genericutils.Id;
  import genericutils.Logger;

  import freeboogie.ast.*; 
  import freeboogie.tc.TypeUtils;
  import static freeboogie.cli.FbCliOptionsInterface.ReportOn;
  import static freeboogie.cli.FbCliOptionsInterface.ReportLevel;
}
@lexer::header {
  package freeboogie.parser;
}

@parser::members {
  public String fileName = null; // the file being processed
  private FileLocation tokLoc(Token t) {
    if (t == null) return FileLocation.unknown();
    return new FileLocation(fileName,t.getLine(),t.getCharPositionInLine()+1);
  }
  private FileLocation fileLoc(Ast a) {
    return a == null? FileLocation.unknown() : a.loc();
  }
  private FileLocation fileLoc(ImmutableList<? extends Ast> al) {
    return al.isEmpty()? FileLocation.unknown() : fileLoc(al.get(0));
  }
  
  public boolean ok = true;

  private ImmutableList.Builder<TypeDecl> typeDeclBuilder;
  private ImmutableList.Builder<Axiom> axiomDeclBuilder;
  private ImmutableList.Builder<VariableDecl> variableDeclBuilder;
  private ImmutableList.Builder<ConstDecl> constDeclBuilder;
  private ImmutableList.Builder<FunctionDecl> functionDeclBuilder;
  private ImmutableList.Builder<Procedure> procedureDeclBuilder;
  private ImmutableList.Builder<Implementation> implementationBuilder;

  private Logger<ReportOn, ReportLevel> out = 
      Logger.<ReportOn, ReportLevel>get("out");

  
  @Override
  public void reportError(RecognitionException x) {
    ok = false;
    super.reportError(x);
  }

  @Override public String getErrorHeader(RecognitionException e) {
    return fileName + ":" + e.line + ":" + (e.charPositionInLine+1) + ":";
  }

}

program returns [Program v]:
    {
      typeDeclBuilder = ImmutableList.builder();
      axiomDeclBuilder = ImmutableList.builder();
      variableDeclBuilder = ImmutableList.builder();
      constDeclBuilder = ImmutableList.builder();
      functionDeclBuilder = ImmutableList.builder();
      procedureDeclBuilder = ImmutableList.builder();
      implementationBuilder = ImmutableList.builder();
    }
    decl* EOF
    { $v = Program.mk(
          fileName,
          typeDeclBuilder.build(),
          axiomDeclBuilder.build(),
          variableDeclBuilder.build(),
          constDeclBuilder.build(),
          functionDeclBuilder.build(),
          procedureDeclBuilder.build(),
          implementationBuilder.build()); }
;

decl:
    type_decl
  | axiom_decl
  | var_decl
  | const_decl
  | fun_decl
  | proc_decl
  | impl_decl
;

type_decl:
    start='type' attribute_list 
    f='finite'? n=ID tv=type_vars ('=' s=type)? ';'
    { if (ok) {
      if ($f!=null && $s.v!=null) {
        out.say(ReportOn.PARSER, ReportLevel.NORMAL, 
          "I'm ignoring 'finite' on the type synonym " + $n.text + ".");
      }
      typeDeclBuilder.add(TypeDecl.mk(
          $attribute_list.v,
          $f != null,
          $n.text,
          $tv.v,
          $s.v,
          tokLoc($start))); }}
;

type_id:
    ID
    { typeDeclBuilder.add(TypeDecl.mk(
          ImmutableList.<Attribute>of(),
          true, // by default all are finite for now
          $ID.text,
          ImmutableList.<AtomId>of(),
          null)); }
;

axiom_decl:
    'axiom' type_vars e=expr ';' 
    { if (ok) axiomDeclBuilder.add(Axiom.mk(
          ImmutableList.<Attribute>of(),
          Id.get("unnamed"),
          $type_vars.v,
          $e.v)); }
;

type_vars returns [ImmutableList<AtomId> v]:
    { $v=ImmutableList.of(); }
  | '<' id_list '>' { if (ok) $v=$id_list.v; }
;

var_decl:
    'var' v=one_var_decl 
    { if (ok) variableDeclBuilder.add($v.v); }
    (',' vv=one_var_decl { if (ok) variableDeclBuilder.add($vv.v);})* ';'
;

one_var_decl returns [VariableDecl v]:
    ID type_vars ':' type 
    { if (ok) {
        $v = VariableDecl.mk(
            ImmutableList.<Attribute>of(),
            $ID.text,
            $type.v,
            $type_vars.v); }}
;

const_decl:
    'const' one_const_decl (',' one_const_decl)* ';'
;

one_const_decl:
    (u='unique')? ID ':' type
    { if (ok) {
      constDeclBuilder.add(ConstDecl.mk(
          ImmutableList.<Attribute>of(),
          $ID.text,
          $type.v,
          $u!=null,
          tokLoc($ID))); }}
;

fun_decl:
    'function' signature ';'
    { if (ok) {
      functionDeclBuilder.add(FunctionDecl.mk(
          ImmutableList.<Attribute>of(),
          $signature.v)); }}
;

proc_decl
scope {
  ImmutableList.Builder<PreSpec> pre;
  ImmutableList.Builder<PostSpec> post;
  ImmutableList.Builder<ModifiesSpec> modifies;
}:
    { $proc_decl::pre = ImmutableList.builder();
      $proc_decl::post = ImmutableList.builder();
      $proc_decl::modifies = ImmutableList.builder(); }
    p='procedure' signature ';'? spec_list
    { if (ok) {
      procedureDeclBuilder.add(Procedure.mk(
          ImmutableList.<Attribute>of(),
          $signature.v,
          $proc_decl::pre.build(),
          $proc_decl::post.build(),
          $proc_decl::modifies.build(),
          tokLoc($p))); }}
    (body
    { if (ok) {
      implementationBuilder.add(Implementation.mk(
          ImmutableList.<Attribute>of(),
          TypeUtils.stripDep($signature.v).clone(),
          $body.v,
          tokLoc($p))); }}
    )?
;

impl_decl:
    s='implementation' signature body
    { if (ok) {
      implementationBuilder.add(Implementation.mk(
          ImmutableList.<Attribute>of(),
          $signature.v,
          $body.v,
          tokLoc($s))); }}
;

signature returns [Signature v]:
  ID tv=type_vars '(' (a=opt_id_type_list)? ')' 
  ('returns' '(' (b=opt_id_type_list)? ')')?
    { if(ok) $v = Signature.mk($ID.text,$tv.v,$a.v,$b.v,tokLoc($ID)); }
;

spec_list:
    spec*
;

spec
scope {
  boolean free;
}
:
      {$spec::free = false;}
    (f='free' {$spec::free = true;})? 
        (((r='requires' | e='ensures') tv=type_vars h=expr
      { if(ok) {
        if ($r != null)
          $proc_decl::pre.add(PreSpec.mk($spec::free, $tv.v, $h.v, fileLoc($h.v)));
        else
          $proc_decl::post.add(PostSpec.mk($spec::free, $tv.v, $h.v, fileLoc($h.v))); }})
    | (m='modifies' id_list { if (ok) $proc_decl::modifies.add(
        ModifiesSpec.mk($spec::free, $id_list.v, tokLoc($m))); } )) ';'
;

body returns [Body v]:
  t='{' vl=var_decl_list b=block_list '}'
    { if(ok) $v = Body.mk($vl.v,$b.v,tokLoc(t)); }
;

var_decl_list returns [ImmutableList<VariableDecl> v]
scope {
	ImmutableList.Builder<VariableDecl> b_;
}
:
      { $var_decl_list::b_ = ImmutableList.builder(); }
    ('var' d=one_var_decl {if (ok) $var_decl_list::b_.add($d.v);} 
    ((',' | ';' 'var') dd=one_var_decl 
      {if (ok) $var_decl_list::b_.add($dd.v);})* ';')?
    { $v=$var_decl_list::b_.build(); }
;

block_list returns [ImmutableList<Block> v]
scope {
  ImmutableList.Builder<Block> builder;
  String nextLabel;
}:
      { $block_list::builder = ImmutableList.builder(); 
        $block_list::nextLabel = null; }
    block+
      { $v = $block_list::builder.build(); }
;

block
scope {
  ArrayList<Command> cmds;
}
: 
    (id=ID ':')? command? (block_succ)?
    { if (ok) {
      FileLocation location = null;
      if ($id != null) location = tokLoc($id);
      else if ($command.v != null) location = fileLoc($command.v);
      else location = fileLoc($block_succ.v);

      String label;
      if ($id == null) {
        label = $block_list::nextLabel == null? 
            Id.get("L") : 
            $block_list::nextLabel;
      } else {
        if ($block_list::nextLabel != null) {
          $block_list::builder.add(Block.mk(
              $block_list::nextLabel,
              null,
              AstUtils.ids($id.text)));
        }
        label = $id.text;
      }
      ImmutableList<AtomId> succ = $block_succ.v;
      if (succ == null) {
        $block_list::nextLabel = Id.get("L");
        succ = AstUtils.ids($block_list::nextLabel);
      } else $block_list::nextLabel = null;
      $block_list::builder.add(Block.mk(
          label,
          $command.v,
          succ,
          location)); }}
;

block_succ returns [ImmutableList<AtomId> v]:
    ('goto' s=id_list | 'return') ';' 
      { $v = s!=null? $s.v : ImmutableList.<AtomId>of(); }
;

command	returns [Command v]:
    a=atom_id i=index_list ':=' b=expr ';' 
      { if(ok) {
          // a[b][c][d][e]:=f --> a:=a[b:=a[b][c:=a[b][c][d:=a[b][c][d][e:=f]]]]
          // grows quadratically
          Expr rhs = $b.v;
          ArrayList<Atom> lhs = new ArrayList<Atom>();
          lhs.add($a.v.clone());
          for (int k = 1; k < $i.v.size(); ++k)
            lhs.add(AtomMapSelect.mk(lhs.get(k-1).clone(), $i.v.get(k-1)));
          for (int k = $i.v.size()-1; k>=0; --k)
            rhs = AtomMapUpdate.mk(lhs.get(k).clone(), ImmutableList.copyOf($i.v.get(k)), rhs);
          $v=AssignmentCmd.mk($a.v,rhs,fileLoc($a.v));
      }}
  | t='assert' tv=type_vars expr ';'
      { if(ok) $v=AssertAssumeCmd.mk(AssertAssumeCmd.CmdType.ASSERT,$tv.v,$expr.v,tokLoc($t)); }
  | t='assume' tv=type_vars expr ';'
      { if(ok) $v=AssertAssumeCmd.mk(AssertAssumeCmd.CmdType.ASSUME,$tv.v,$expr.v,tokLoc($t)); }
  | t='havoc' id_list ';'
      { if(ok) $v=HavocCmd.mk($id_list.v,tokLoc($t));}
  | t='call' call_lhs
    n=ID st=quoted_simple_type_list '(' (r=expr_list)? ')' ';'
      { if(ok) $v=CallCmd.mk($n.text,$st.v,$call_lhs.v,$r.v,tokLoc($t)); }
;

call_lhs returns [ImmutableList<AtomId> v]:
    (id_list ':=')=> il=id_list ':=' {$v=$il.v;}
  | {$v=ImmutableList.<AtomId>of();}
;
	
index returns [ImmutableList<Expr> v]:
  '[' expr_list ']' { $v = $expr_list.v; }
;

/* {{{ BEGIN expression grammar.

   See http://www.engr.mun.ca/~theo/Misc/exp_parsing.htm
   for a succint presentation of how to implement precedence
   and associativity in a LL-grammar, the classical way.

   The precedence increases
     <==>
     ==>
     &&, ||
     =, !=, <, <=, >=, >, <:
     +, -
     *, /, %

   <==> is associative
   ==> is right associative
   Others are left associative.
   The unary operators are ! and -.
   Typechecking takes care of booleans added to integers 
   and the like.
 */

expr returns [Expr v]:
  l=expr_a {$v=$l.v;} 
    (t='<==>' r=expr_a {if(ok) $v=BinaryOp.mk(BinaryOp.Op.EQUIV,$v,$r.v,tokLoc($t));})*
;

expr_a returns [Expr v]: 
  l=expr_b {$v=$l.v;} 
    (t='==>' r=expr_a {if(ok) $v=BinaryOp.mk(BinaryOp.Op.IMPLIES,$v,$r.v,tokLoc($t));})?
;

// TODO: these do not keep track of location quite correctly
expr_b returns [Expr v]:
  l=expr_c {$v=$l.v;} 
    (op=and_or_op r=expr_c {if(ok) $v=BinaryOp.mk($op.v,$v,$r.v,fileLoc($r.v));})*
;

expr_c returns [Expr v]:
  l=expr_d {$v=$l.v;}
    (op=comp_op r=expr_d {if(ok) $v=BinaryOp.mk($op.v,$v,$r.v,fileLoc($r.v));})*
;

expr_d returns [Expr v]:
  l=expr_e {$v=$l.v;}
    (op=add_op r=expr_e {if(ok) $v=BinaryOp.mk($op.v,$v,$r.v,fileLoc($r.v));})*
;

expr_e returns [Expr v]: 
  l=expr_f {$v=$l.v;}
    (op=mul_op r=expr_f {if(ok) $v=BinaryOp.mk($op.v,$v,$r.v,fileLoc($r.v));})*
;

expr_f returns [Expr v]:
    m=atom ('[' idx=expr_list (':=' val=expr)? ']')?
      { if (ok) {
        if ($idx.v == null) 
          $v=$m.v;
        else if ($val.v == null) 
          $v=AtomMapSelect.mk($m.v,$idx.v,fileLoc($m.v));
        else 
          $v=AtomMapUpdate.mk($m.v,$idx.v,$val.v,fileLoc($m.v));
      }}
  | '(' expr ')' {$v=$expr.v;}
  | t='-' a=expr_f   {if(ok) $v=UnaryOp.mk(UnaryOp.Op.MINUS,$a.v,tokLoc($t));}
  | t='!' a=expr_f   {if(ok) $v=UnaryOp.mk(UnaryOp.Op.NOT,$a.v,tokLoc($t));}
;

and_or_op returns [BinaryOp.Op v]:
    '&&' { $v = BinaryOp.Op.AND; }
  | '||' { $v = BinaryOp.Op.OR; }
;

comp_op returns [BinaryOp.Op v]:
    '==' { $v = BinaryOp.Op.EQ; }
  | '!=' { $v = BinaryOp.Op.NEQ; }
  | '<'  { $v = BinaryOp.Op.LT; }
  | '<=' { $v = BinaryOp.Op.LE; }
  | '>=' { $v = BinaryOp.Op.GE; }
  | '>'  { $v = BinaryOp.Op.GT; }
  | '<:' { $v = BinaryOp.Op.SUBTYPE; }
;

add_op returns [BinaryOp.Op v]:
    '+' { $v = BinaryOp.Op.PLUS; }
  | '-' { $v = BinaryOp.Op.MINUS; }
;

mul_op returns [BinaryOp.Op v]:
    '*' { $v = BinaryOp.Op.MUL; }
  | '/' { $v = BinaryOp.Op.DIV; }
  | '%' { $v = BinaryOp.Op.MOD; }
;

atom returns [Atom v]
scope {
  ImmutableList<Type> typeArgs;
}
:
    t='false' { if(ok) $v = AtomLit.mk(AtomLit.AtomType.FALSE,tokLoc($t)); }
  | t='true'  { if(ok) $v = AtomLit.mk(AtomLit.AtomType.TRUE,tokLoc($t)); }
  | t='null'  { if(ok) $v = AtomLit.mk(AtomLit.AtomType.NULL,tokLoc($t)); }
  | t=INT     { if(ok) $v = AtomNum.mk(new BigInteger($INT.text),tokLoc($t)); }
  |	t=ID ('<' st=quoted_simple_type_list '>')? 
              { if(ok) {
                $atom::typeArgs = $st.v;
                if ($atom::typeArgs == null) 
                  $atom::typeArgs = ImmutableList.of();
                $v = AtomId.mk($t.text,$atom::typeArgs,tokLoc($t)); }}
    ('(' (p=expr_list?) ')'
              { if(ok) $v = AtomFun.mk($t.text,$atom::typeArgs,$p.v,tokLoc($t)); }
    )?
  | t='old' '(' expr ')'
              { if(ok) $v = AtomOld.mk($expr.v,tokLoc($t)); }
  | t='cast' '(' expr ',' type ')'
              { if(ok) $v = AtomCast.mk($expr.v, $type.v,tokLoc($t)); }
  | t='(' a=quant_op b=id_type_list '::' c=attributes d=expr ')'
              { if(ok) $v = AtomQuant.mk($a.v,$b.v,$c.v,$d.v,tokLoc($t)); }
;

atom_id returns [AtomId v]:
    ID ('<' st=quoted_simple_type_list '>')?
      { if(ok) {
        ImmutableList<Type> typeArgs = $st.v;
        if (typeArgs == null) typeArgs = ImmutableList.of();
        $v = AtomId.mk($ID.text,typeArgs,tokLoc($ID)); }}
;

// END of the expression grammar }}}
	
quant_op returns [AtomQuant.QuantType v]:
    'forall' { $v = AtomQuant.QuantType.FORALL; }
  | 'exists' { $v = AtomQuant.QuantType.EXISTS; }
;

attributes returns [ImmutableList<Attribute> v]
scope {
  ImmutableList.Builder<Attribute> builder;
}:
    { $attributes::builder = ImmutableList.builder(); }
    (attr {if (ok) $attributes::builder.add($attr.v);})*
    { $v = $attributes::builder.build(); }
;

attr returns [Attribute v]:
    a='{' (':' ID)? c=expr_list '}'
      { if(ok) $v=Attribute.mk($ID==null?"trigger":$ID.text,$c.v,tokLoc($a)); }
;


// {{{ BEGIN list rules 

attribute_list returns [ImmutableList<Attribute> v]: /* TODO */ ;
	
expr_list returns [ImmutableList<Expr> v]
scope {
  ImmutableList.Builder<Expr> builder;
}:
    { $expr_list::builder = ImmutableList.builder(); }
    e=expr {if(ok)$expr_list::builder.add($e.v);} 
    (',' ee=expr {if(ok)$expr_list::builder.add($ee.v);})*
    { $v = $expr_list::builder.build(); }
;

id_list	returns [ImmutableList<AtomId> v]
scope {
  ImmutableList.Builder<AtomId> b_;
}
:	
      { $id_list::b_ = ImmutableList.builder(); }
    h=atom_id {if (ok) $id_list::b_.add($h.v); }
    (',' t=atom_id { if (ok) $id_list::b_.add($t.v); })*
      { $v = $id_list::b_.build(); }
;

quoted_simple_type_list returns [ImmutableList<Type> v]
scope {
  ImmutableList.Builder<Type> builder;
}:
      { $quoted_simple_type_list::builder = ImmutableList.builder(); }
    ('<' '`' t=simple_type {if(ok)$quoted_simple_type_list::builder.add($t.v);} 
    (',' '`' tt=simple_type {if(ok)$quoted_simple_type_list::builder.add($tt.v);})* '>')?
      { $v = $quoted_simple_type_list::builder.build(); }
;

simple_type_list returns [ImmutableList<Type> v]
scope {
  ImmutableList.Builder<Type> builder;
}:
      { $simple_type_list::builder = ImmutableList.builder(); }
    (t=simple_type {if(ok)$simple_type_list::builder.add($t.v);} 
    (',' tt=simple_type {if(ok)$simple_type_list::builder.add($tt.v);})*)?
      { $v = $simple_type_list::builder.build(); }
;

opt_id_type_list returns [ImmutableList<VariableDecl> v]
scope {
  ImmutableList.Builder<VariableDecl> builder;
}:
    { $opt_id_type_list::builder = ImmutableList.builder(); }
    x=opt_id_type {if(ok)$opt_id_type_list::builder.add($x.v);} 
    (',' xx=opt_id_type {if(ok)$opt_id_type_list::builder.add($xx.v);})*
    { $v = $opt_id_type_list::builder.build(); }
;

opt_id_type returns [VariableDecl v]
scope {
  String n;
  ImmutableList<AtomId> tv;
}:
    { $opt_id_type::n = Id.get("unnamed"); 
      $opt_id_type::tv = ImmutableList.of(); }
    (ID {$opt_id_type::n = $ID.text;} type_vars {$opt_id_type::tv=$type_vars.v;} ':')? type
    {if (ok) $v=VariableDecl.mk(ImmutableList.<Attribute>of(),$opt_id_type::n,$type.v,$opt_id_type::tv,fileLoc($type.v));}
;

id_type_list returns [ImmutableList<VariableDecl> v]
scope {
  ImmutableList.Builder<VariableDecl> builder;
}:
    {$id_type_list::builder = ImmutableList.builder();}
    x=id_type { if(ok) $id_type_list::builder.add($x.v); }
    (',' xx=id_type {if (ok) $id_type_list::builder.add($xx.v);})*
    {$v=$id_type_list::builder.build();}
;

id_type returns [VariableDecl v]:
    i=ID tv=type_vars ':' t=type
    {if (ok) $v = VariableDecl.mk(ImmutableList.<Attribute>of(),$i.text,$t.v,$tv.v,tokLoc(i));}
;

command_list returns [ArrayList<Command> v]:
  {if (ok) $v = new ArrayList<Command>();}
  (c=command {if (ok) $v.add($c.v);})*
;

index_list returns [ArrayList<ImmutableList<Expr>> v]:
  { $v = Lists.newArrayList(); }
  (i=index {$v.add($i.v);})*
;
	
// END list rules }}}


simple_type returns [Type v]:
    t='bool' { if(ok) $v = PrimitiveType.mk(PrimitiveType.Ptype.BOOL,-1,tokLoc($t)); }
  | t='int'  { if(ok) $v = PrimitiveType.mk(PrimitiveType.Ptype.INT,-1,tokLoc($t)); }
  | t='ref'  { if(ok) $v = PrimitiveType.mk(PrimitiveType.Ptype.REF,-1,tokLoc($t)); }
  | t='name' { if(ok) $v = PrimitiveType.mk(PrimitiveType.Ptype.NAME,-1,tokLoc($t)); }
  | t='any'  { if(ok) $v = PrimitiveType.mk(PrimitiveType.Ptype.ANY,-1,tokLoc($t)); }
  | t=ID     { if(ok) $v = UserType.mk($ID.text,ImmutableList.<Type>of(),tokLoc($t)); }
  | t='[' it=simple_type_list ']' et=simple_type
             { if(ok) $v = MapType.mk($it.v,$et.v,tokLoc($t)); }
  | t='<' p=simple_type '>' st=simple_type
             { if(ok) $v = IndexedType.mk($p.v,$st.v,tokLoc($t)); }
;

type returns [Type v]:
  t=simple_type ('where' p=expr)?
    {  if (ok) {
         if ($p.v==null) $v=$t.v;
         else $v=DepType.mk($t.v,$p.v,fileLoc($t.v));
    }}
;
	
ID:
  ('a'..'z'|'A'..'Z'|'\''|'~'|'#'|'$'|'.'|'?'|'_'|'^'|'\\')
  ('a'..'z'|'A'..'Z'|'\''|'~'|'#'|'$'|'.'|'?'|'_'|'^'|'`'|'0'..'9')*
;
	
INT     : 	'0'..'9'+ ;
WS      : 	(' '|'\t'|'\n'|'\r')+ {$channel=HIDDEN;};
COMMENT
    :   '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
    ;

LINE_COMMENT
    : '//' ~('\n'|'\r')* ('\r'|'\n') {$channel=HIDDEN;}
    ;

