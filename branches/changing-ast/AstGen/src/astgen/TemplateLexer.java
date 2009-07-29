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

  private int maxMacroLen;
  private Map<String, ArrayList<TemplateToken>> userShorthands = Maps.newHashMap();
  private int bufferIndex;
  private ArrayList<TemplateToken> buffer;

  /** 
   * Initialize a lexer. 
   * @param stream the underlying character stream
   */
  public TemplateLexer(CharStream stream) {
    super(new TokenLocation<TemplateToken>());
    this.stream = stream;
    lastChar = null;

    maxMacroLen = 0;
    for (String s : macros.keySet())
      maxMacroLen = Math.max(maxMacroLen, s.length());
  }
  
  @Override
  public String getName() {
    return stream.getName();
  }

  public void userShorthand(String t, ArrayList<TemplateToken> b) {
    String m = "\\" + t;
    userShorthands.put(m, b);
    maxMacroLen = Math.max(maxMacroLen, m.length());
  }
  
  /*
   * This method always reads ahead one character.
   *  
   * @see astgen.PeekStream#read() 
   * @see astgen.AgLexer#read()
   */
  @Override
  protected TemplateToken read() throws IOException {
    if (buffer != null && bufferIndex < buffer.size()) {
      return buffer.get(bufferIndex++);
    }

    if (lastChar == null) lastChar = stream.next();
    if (lastChar == null) return null;
    
    TemplateToken.Type type = oneCharTokens.get(lastChar);
    TemplateToken.Case idCase = null;
    sb = new StringBuilder();
    sb.append(lastChar);
    
    if (type != null) {
      lastChar = stream.next();
    } else if (lastChar == '\\') {
      stream.mark();
      // read the macro
      while (
          sb.length() <= maxMacroLen && 
          !macros.containsKey(sb.toString()) &&
          !userShorthands.containsKey(sb.toString())) {
        lastChar = stream.next();
        sb.append(lastChar);
      }
      if (sb.length() > maxMacroLen) {
        err("Please don't use '\\' outside macro names: <" + sb + ">.");
        sb.setLength(0);
        sb.append('\\');
        stream.rewind();
        lastChar = null;
        type = TemplateToken.Type.OTHER;
      } else if (lastChar == null) {
        err("The template ends abruptly while I was reading a macro: " + sb);
        type = TemplateToken.Type.OTHER;
      } else {
        lastChar = stream.next();
        buffer = userShorthands.get(sb.toString());
System.err.print("[Searched " + sb + "]");
        if (buffer != null) {
System.err.print("[Expanding " + sb + "]");
          bufferIndex = 0;
          return read();
        }
        type = macros.get(sb.toString());
        idCase = idCases.get(sb.toString());
      }
    } else {
      // read in plain text
      type = TemplateToken.Type.OTHER;
      lastChar = stream.next();
      while (lastChar != null && lastChar != '\\' 
        && !oneCharTokens.containsKey(lastChar)
      ) {
        sb.append(lastChar);
        lastChar = stream.next();
      }
    }
    
    stream.eat();
    if (idCase == null) idCase = TemplateToken.Case.ORIGINAL_CASE;
    return new TemplateToken(type, sb.toString(), idCase);
  }
  
  private void err(String e) {
    Err.error(getName() + stream.getLoc() + ": " + e);
  }
}
