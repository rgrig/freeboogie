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
  @SuppressWarnings("serial")
  private static class IntRangeException extends RecognitionException {
    private String value;
    public IntRangeException(String value, IntStream input) {
      super(input);
      this.value = value;
    }
    @Override public String getMessage() {
      return "Integer " + value + " is too big.";
    }
  }

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
  
  public boolean ok = true;  // set to false while testing (only) the grammar

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

// BEGIN top level declarations {{{
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
          ImmutableList.<Identifier>of(),
          null)); }
;

axiom_decl:
    'axiom' e=expr ';' 
    { if (ok) axiomDeclBuilder.add(Axiom.mk(
          ImmutableList.<Attribute>of(),
          Id.get("unnamed"),
          AstUtils.ids(),
          $e.v)); }
;

var_decl:
    'var' v=one_var_decl 
    { if (ok) variableDeclBuilder.add($v.v); }
    (',' vv=one_var_decl { if (ok) variableDeclBuilder.add($vv.v);})* ';'
;

one_var_decl returns [VariableDecl v]:
    ID ':' type ('where' expr)?
    { if (ok) {
        $v = VariableDecl.mk(
            ImmutableList.<Attribute>of(),
            $ID.text,
            $type.v,
            AstUtils.ids(),
            $expr.v,
            tokLoc($ID)); }}
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

// TODO (radugrigore): keep track of expr
fun_decl:
    'function' signature (';' | '{' expr '}')
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
  ID tv=type_args '(' (a=opt_id_type_list)? ')' 
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
        (((r='requires' | e='ensures') h=expr
      { if(ok) {
        if ($r != null)
          $proc_decl::pre.add(PreSpec.mk($spec::free, AstUtils.ids(), $h.v, fileLoc($h.v)));
        else
          $proc_decl::post.add(PostSpec.mk($spec::free, AstUtils.ids(), $h.v, fileLoc($h.v))); }})
    | (m='modifies' id_list { if (ok) $proc_decl::modifies.add(
        ModifiesSpec.mk($spec::free, $id_list.v, tokLoc($m))); } )) ';'
;

attr returns [Attribute v]:
    a='{' (':' ID)? c=expr_list '}'
      { if(ok) $v=Attribute.mk($ID==null?"trigger":$ID.text,$c.v,tokLoc($a)); }
;
// END top level declarations }}}

// BEGIN body {{{
body returns [Body v]:
  t='{' vl=var_decl_list b=block last='}'
    { if(ok) {
      // add a return at the end if there isn't one (or at least a goto)
      Block bl = $b.v;
      ImmutableList<Command> cs = b.commands();
      if (cs.isEmpty() || !(cs.get(cs.size()-1) instanceof GotoCmd)) {
        ImmutableList.Builder<Command> builder = ImmutableList.builder();
        builder.addAll(cs);
        builder.add(GotoCmd.mk(
            ImmutableList.<String>of(),
            ImmutableList.<String>of(),
            tokLoc($last)));
        bl = Block.mk(builder.build(), bl.loc());
      }
      $v = Body.mk($vl.v,bl,tokLoc(t)); }}
;

block returns [Block v]:
    cl=command_list
    { if (ok) $v = Block.mk($cl.v, fileLoc($cl.v)); }
;

command_list returns [ImmutableList<Command> v]
scope {
  ImmutableList.Builder<Command> b;
}:
    { $command_list::b = ImmutableList.builder(); }
    (c=command {if (ok) $command_list::b.add($c.v);})*
    { $v = $command_list::b.build(); }
;

command	returns [Command v]:
  label_list
  (
      a=atom_id i=index_list ':=' b=expr ';' 
        { if(ok) {
            // a[b][c][d][e]:=f --> a:=a[b:=a[b][c:=a[b][c][d:=a[b][c][d][e:=f]]]]
            // grows quadratically
            Expr rhs = $b.v;
            ArrayList<Expr> lhs = new ArrayList<Expr>();
            lhs.add($a.v.clone());
            for (int k = 1; k < $i.v.size(); ++k)
              lhs.add(MapSelect.mk(lhs.get(k-1).clone(), $i.v.get(k-1)));
            for (int k = $i.v.size()-1; k>=0; --k)
              rhs = MapUpdate.mk(lhs.get(k).clone(), ImmutableList.copyOf($i.v.get(k)), rhs);
            $v=AssignmentCmd.mk($label_list.v,$a.v,rhs,fileLoc($a.v));
        }}
    | t='assert' ae=expr ';'
        { if(ok) $v=AssertAssumeCmd.mk($label_list.v,AssertAssumeCmd.CmdType.ASSERT,AstUtils.ids(),$ae.v,tokLoc($t)); }
    | t='assume' be=expr ';'
        { if(ok) $v=AssertAssumeCmd.mk($label_list.v,AssertAssumeCmd.CmdType.ASSUME,AstUtils.ids(),$be.v,tokLoc($t)); }
    | t='havoc' hv=id_list ';'
        { if(ok) $v=HavocCmd.mk($label_list.v,$hv.v,tokLoc($t));}
    | t='call' call_lhs n=ID '(' (r=expr_list)? ')' ';'
        { if(ok) $v=CallCmd.mk($label_list.v,$n.text,ImmutableList.<Type>of(),$call_lhs.v,$r.v,tokLoc($t)); }
    | (t='goto' ll=label_comma_list | t='return') ';'
        { if (ok) { $v = GotoCmd.mk($label_list.v, $ll.v, tokLoc($t)); }}
  )
;

call_lhs returns [ImmutableList<Identifier> v]:
    (id_list ':=')=> il=id_list ':=' {$v=$il.v;}
  | {$v=ImmutableList.<Identifier>of();}
;
// END body }}}
	
/* {{{ BEGIN expression grammar.

   See http://www.engr.mun.ca/~theo/Misc/exp_parsing.htm
   for a succint presentation of how to implement precedence
   and associativity in a LL-grammar, the classical way.

   The precedence increases
     <==>
     ==>
     &&, ||
     =, !=, <, <=, >=, >, <:
     ++
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
  ('++' r=expr_e {if (ok) $v=BinaryOp.mk(BinaryOp.Op.CONCAT,$v,$r.v,fileLoc($v));})*
;

expr_e returns [Expr v]:
  l=expr_f {$v=$l.v;}
    (op=add_op r=expr_f {if(ok) $v=BinaryOp.mk($op.v,$v,$r.v,fileLoc($r.v));})*
;

expr_f returns [Expr v]: 
  l=expr_g {$v=$l.v;}
    (op=mul_op r=expr_g {if(ok) $v=BinaryOp.mk($op.v,$v,$r.v,fileLoc($r.v));})*
;

expr_g returns [Expr v]:
    expr_h 
    { $v = $expr_h.v; }
  | unary_op e=expr_g 
    { if (ok) $v=UnaryOp.mk($unary_op.v,$e.v,fileLoc($e.v)); }
;

expr_h returns [Expr v]:
  atom { $v = $atom.v; }
  (s='[' ((expr_list (':=' expr)?  
    { if (ok) { $v = $expr.v == null?
          MapSelect.mk($v,$expr_list.v,tokLoc($s)) :
          MapUpdate.mk($v,$expr_list.v,$expr.v,tokLoc($s)); }})
  | (l=number ':' h=number
    { if (ok) $v = Slice.mk($v,$l.v,$h.v,fileLoc($l.v));})) ']')*
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

unary_op returns [UnaryOp.Op v]:
    '-' { $v = UnaryOp.Op.MINUS; }
  | '!' { $v = UnaryOp.Op.NOT; }
;

atom returns [Expr v]
scope {
  ImmutableList<Type> typeArgs;
}
:
    t='false' { if(ok) $v = BooleanLiteral.mk(BooleanLiteral.Type.FALSE,tokLoc($t)); }
  | t='true'  { if(ok) $v = BooleanLiteral.mk(BooleanLiteral.Type.TRUE,tokLoc($t)); }
  | n=number  { if(ok) $v = $n.v; }
  |	t=ID 
              { if(ok) {
                $v = Identifier.mk($t.text,ImmutableList.<Type>of(),tokLoc($t)); }}
    ('(' (p=expr_list?) ')'
              { if(ok) $v = FunctionApp.mk($t.text,$atom::typeArgs,$p.v,tokLoc($t)); }
    )?
  | t='old' '(' expr ')'
              { if(ok) $v = OldExpr.mk($expr.v,tokLoc($t)); }
  | t='(' a=quant_op type_args b=id_type_list '::' c=attributes d=expr ')'
              { if(ok) $v = Quantifier.mk($a.v,$b.v,$c.v,$d.v,tokLoc($t)); }
  | '(' expr ')'  { $v = $expr.v; }
;

atom_id returns [Identifier v]:
    ID 
      { if(ok) {
        $v = Identifier.mk($ID.text,ImmutableList.<Type>of(),tokLoc($ID)); }}
;

index returns [ImmutableList<Expr> v]:
  '[' expr_list ']' { $v = $expr_list.v; }
;

quant_op returns [Quantifier.QuantType v]:
    'forall' { $v = Quantifier.QuantType.FORALL; }
  | 'exists' { $v = Quantifier.QuantType.EXISTS; }
;

// END of the expression grammar }}}

// {{{ BEGIN list rules 

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

attributes returns [ImmutableList<Attribute> v]
scope {
  ImmutableList.Builder<Attribute> builder;
}:
    { $attributes::builder = ImmutableList.builder(); }
    (attr {if (ok) $attributes::builder.add($attr.v);})*
    { $v = $attributes::builder.build(); }
;

label_list returns [ImmutableList<String> v]
scope {
  ImmutableList.Builder<String> b;
}:
    { $label_list::b = ImmutableList.builder(); }
    (ID ':' { $label_list::b.add($ID.text); })*
    { $v = $label_list::b.build(); }
;

label_comma_list returns [ImmutableList<String> v]
scope {
  ImmutableList.Builder<String> b;
}:
    { $label_comma_list::b = ImmutableList.builder(); }
    (h=ID { $label_comma_list::b.add($h.text); }
    (',' t=ID { $label_comma_list::b.add($t.text); })*)?
    { $v = $label_comma_list::b.build(); }
;


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

id_list	returns [ImmutableList<Identifier> v]
scope {
  ImmutableList.Builder<Identifier> b_;
}
:	
      { $id_list::b_ = ImmutableList.builder(); }
    h=atom_id {if (ok) $id_list::b_.add($h.v); }
    (',' t=atom_id { if (ok) $id_list::b_.add($t.v); })*
      { $v = $id_list::b_.build(); }
;

type_list returns [ImmutableList<Type> v]
scope {
  ImmutableList.Builder<Type> builder;
}:
    { $type_list::builder = ImmutableList.builder(); }
    (t=type {if(ok)$type_list::builder.add($t.v);} 
    (',' tt=type {if(ok)$type_list::builder.add($tt.v);})*)?
    { $v = $type_list::builder.build(); }
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
}:
    { $opt_id_type::n = Id.get("unnamed");  }
    (ID {$opt_id_type::n = $ID.text;} ':')? type ('where' expr)?
    { if (ok) $v=VariableDecl.mk(
        ImmutableList.<Attribute>of(),
        $opt_id_type::n,
        $type.v,
        AstUtils.ids(),
        $expr.v,
        fileLoc($type.v)); }
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
    i=ID ':' t=type
    { if (ok) {
      $v = VariableDecl.mk(
          ImmutableList.<Attribute>of(),
          $i.text,
          $t.v,
          AstUtils.ids(),
          null,
          tokLoc(i)); }}
;

index_list returns [ArrayList<ImmutableList<Expr>> v]:
  { $v = Lists.newArrayList(); }
  (i=index {$v.add($i.v);})*
;
	
type_vars returns [ImmutableList<Identifier> v]
scope {
  ImmutableList.Builder<Identifier> b;
}:
    { $type_vars::b = ImmutableList.builder(); }
    (ID { $type_vars::b.add(Identifier.mk($ID.text, ImmutableList.<Type>of())); })*
    { $v = $type_vars::b.build(); }
;


// END list rules }}}

// BEGIN type rules {{{
type returns [Type v]: 
    type_atom  { $v = $type_atom.v; }
  | map_type   { $v = $map_type.v; }
  | user_type  { $v = $user_type.v; }
;

type_atom returns [Type v]: 
    primitive_type  { $v = $primitive_type.v; }
  | '(' type ')' { $v = $type.v; }
;

primitive_type returns [PrimitiveType v]: 
    s='bool' 
    { if (ok) $v = PrimitiveType.mk(PrimitiveType.Ptype.BOOL, -1, tokLoc($s)); }
  | s='int' 
    { if (ok) $v = PrimitiveType.mk(PrimitiveType.Ptype.INT, -1, tokLoc($s)); }
  | s=BIT_VECTOR
    { if (ok) {
      String x = $s.text.substring(2, $s.text.length());
      if (x.length() < 10)
        $v = PrimitiveType.mk(PrimitiveType.Ptype.INT, Integer.parseInt(x)); 
      else throw new IntRangeException(x, input); }}
;

map_type returns [MapType v]: 
    ta=type_args s='[' idx=type_list ']' type
    { if (ok) { $v = MapType.mk($idx.v, $type.v, tokLoc($s)); }}
    // TODO (radugrigore): keep track of type arguments
;

type_args returns [ImmutableList<Identifier> v]:
    { $v=ImmutableList.of(); }
  | '<' id_list '>' { if (ok) $v=$id_list.v; }
;

user_type returns [UserType v]
scope {
  ImmutableList.Builder<Type> b;
}:
    { $user_type::b = ImmutableList.builder(); }
    n=ID 
    (ti=ID 
    {if (ok) {
      $user_type::b.add(UserType.mk(
          $ti.text, 
          ImmutableList.<Type>of(),
          tokLoc($ti))); }}
    | ta=type_atom { if (ok) $user_type::b.add($ta.v);})* 
    (tm=map_type { if (ok) $user_type::b.add($tm.v);})?
    { if (ok) { $v = UserType.mk($n.text, $user_type::b.build(), tokLoc($n)); }}
;

// END type rules }}}

// BEGIN lexer (plus small helpers from the parser) {{{

number returns [NumberLiteral v]: INT {
  String x = $INT.text;
  String y = null;
  int i = x.indexOf("bv");
  if (i != -1) { 
    y = x.substring(i + 2, x.length());
    x = x.substring(0, i);
    int bits;
    try { bits = Integer.parseInt(y); }
    catch (NumberFormatException e) {
      throw new IntRangeException(y, input);
    }
    return NumberLiteral.mk(new FbInteger(new BigInteger(x), bits), tokLoc($INT));
  }
  return NumberLiteral.mk(new FbInteger(new BigInteger(x), -1), tokLoc($INT));
};

BIT_VECTOR: 'bv' ('0'..'9')+;

ID:
  ('a'..'z'|'A'..'Z'|'\''|'~'|'#'|'$'|'.'|'?'|'_'|'^'|'\\')
  ('a'..'z'|'A'..'Z'|'\''|'~'|'#'|'$'|'.'|'?'|'_'|'^'|'`'|'0'..'9')*
;
	
INT     : 	'0'..'9'+ ('bv' '0'..'9'+)?;
WS      : 	(' '|'\t'|'\n'|'\r')+ {$channel=HIDDEN;};
COMMENT
    :   '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
    ;

LINE_COMMENT
    : '//' ~('\n'|'\r')* ('\r'|'\n') {$channel=HIDDEN;}
    ;
// END lexer }}}
