package astgen;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import genericutils.Err;

/**
 * Lexer for template files. The macros and the delimiters they use 
 * are recognized; everything in-between is considered as the token
 * `other' and will be later copied verbatim to the output. 
 * 
 * @author rgrig 
 */
public class TemplateLexer extends PeekStream<TemplateToken> {
  
  private CharStream stream;
  private Character lastChar;
  private StringBuilder sb;
  
  private static final Map<String, TemplateToken.Type> macros =
      Maps.newHashMapWithExpectedSize(101);
  private static final Map<Character, TemplateToken.Type> oneCharTokens =
      Maps.newHashMapWithExpectedSize(11);
  private static final Map<String, TemplateToken.Case> idCases =
      Maps.newHashMapWithExpectedSize(7);
  
  static {
    // Note that "\lp" and "\LP" will behave the same as "(".
    for (TemplateToken.Type t : TemplateToken.Type.values()) {
      for (TemplateToken.Case c : TemplateToken.Case.values()) {
        String m = "\\" + c.convertId(t.name(), true);
        macros.put(m, t);
        idCases.put(m, c);
      }
    }
    
    oneCharTokens.put('(', TemplateToken.Type.LP);
    oneCharTokens.put(')', TemplateToken.Type.RP);
    oneCharTokens.put('[', TemplateToken.Type.LB);
    oneCharTokens.put(']', TemplateToken.Type.RB);
    oneCharTokens.put('{', TemplateToken.Type.LC);
    oneCharTokens.put('}', TemplateToken.Type.RC);
    oneCharTokens.put('|', TemplateToken.Type.OR);
    oneCharTokens.put('&', TemplateToken.Type.AND);
  }

  /** 
   * Initialize a lexer. 
   * @param stream the underlying character stream
   */
  public TemplateLexer(CharStream stream) {
    super(new TokenLocation<TemplateToken>());
    this.stream = stream;
    lastChar = null;
  }
  
  @Override
  public String getName() {
    return stream.getName();
  }
  
  /*
   * This method always reads ahead one character.
   *  
   * @see astgen.PeekStream#read() 
   * @see astgen.AgLexer#read()
   */
  @Override
  protected TemplateToken read() throws IOException {
    if (lastChar == null) lastChar = stream.next();
    if (lastChar == null) return null;
    
    TemplateToken.Type type = oneCharTokens.get(lastChar);
    TemplateToken.Case idCase = null;
    sb = new StringBuilder();
    
    if (type != null) {
      sb.append(lastChar);
      lastChar = stream.next();
    } else if (lastChar == '\\') {
      do sb.append(lastChar);
      while (Character.isLetter(lastChar = stream.next()) || lastChar == '_');
      type = macros.get(sb.toString());
      idCase = idCases.get(sb.toString());
    } else {
      // read in plain text
      type = TemplateToken.Type.OTHER;
      do sb.append(lastChar);
      while (
          (lastChar = stream.next()) != null && 
          lastChar != '\\' &&
          !oneCharTokens.containsKey(lastChar));
    }
    
    stream.eat();
    if (type == null) type = TemplateToken.Type.OTHER;
    if (idCase == null) idCase = TemplateToken.Case.ORIGINAL_CASE;
//System.err.println("<" + sb + ">");
    return new TemplateToken(type, sb.toString(), idCase);
  }
  
  private void err(String e) {
    Err.error(getName() + stream.getLoc() + ": " + e);
  }
}
