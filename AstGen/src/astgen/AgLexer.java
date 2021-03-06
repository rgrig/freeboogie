package astgen;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Recognizes abstract grammar (AG) tokens.
 * 
 * @author rgrig 
 */
public class AgLexer extends PeekStream<AgToken> {
  
  private static final Map<Character, AgToken.Type> oneCharTokens
    = new HashMap<Character, AgToken.Type>(17);
  
  static {
    oneCharTokens.put('=', AgToken.Type.EQ);
    oneCharTokens.put('!', AgToken.Type.BANG);
    oneCharTokens.put(',', AgToken.Type.COMMA);
    oneCharTokens.put(';', AgToken.Type.SEMICOLON);
    oneCharTokens.put('(', AgToken.Type.LP);
    oneCharTokens.put(')', AgToken.Type.RP);
    oneCharTokens.put('[', AgToken.Type.LB);
    oneCharTokens.put(']', AgToken.Type.RB);
    oneCharTokens.put('\n', AgToken.Type.NL);
  }
  
  private CharStream stream;
  private CharToken lastToken;
  private char lastChar;
  private StringBuilder repBuilder;
  
  /**
   * Initializes the lexer.
   * @param stream the underlying stream
   * @throws IOException if thrown by the underlying stream
   */
  public AgLexer(CharStream stream) throws IOException {
    this.stream = stream;
    repBuilder = new StringBuilder();
    readChar();
  }
  
  private void readChar() throws IOException {
    if (lastToken != null) repBuilder.append(lastChar);
    lastToken = stream.next(false);
    if (lastToken != null) lastChar = lastToken.c();
  }

  private String rep() {
    String r = repBuilder.toString();
    repBuilder.setLength(0);
    return r;
  }
  
  /*
   * This method always reads one more character than the recognized
   * token and also eats the read characters from the underlying stream.
   *
   * The method is a bit too complex but lexers usually are.
   * 
   * @see astgen.PeekStream#read()
   */
  @Override
  protected AgToken read() throws IOException {
    if (lastToken == null) return null;
    
    AgToken.Type type = oneCharTokens.get(lastChar);
    if (type != null) {
      readChar();
    } else if (Character.isWhitespace(lastChar)) {
      type = AgToken.Type.WS;
      do readChar(); 
      while (lastToken != null && Character.isWhitespace(lastChar));
    } else if (lastChar == ':') {
      readChar();
      if (lastChar == '>') { 
        type = AgToken.Type.SUPERTYPE;
        readChar();
      } else 
        type = AgToken.Type.COLON;
    } else if (lastChar == '/') {
      readChar();
      if (lastChar != '/') type = AgToken.Type.ERROR;
      else {
        type = AgToken.Type.COMMENT;
        while (lastChar != '\n') readChar();
        readChar();
      }
    } else if (isIdFirstCharacter(lastChar)) {
      do readChar();
      while (isIdCharacter(lastChar));
      if (repBuilder.toString().equals("enum")) 
        type = AgToken.Type.ENUM;
      else type = AgToken.Type.ID;
    } else {
      type = AgToken.Type.ERROR;
      readChar();
    }
    
    stream.unmark();
    return new AgToken(type, rep());
  }
  
  /**
   * Like {@code next}, but skips WS, COMMENT, and ERROR tokens.
   * It also gives error messages for ERROR tokens.
   * @return the next good token
   * @throws IOException if thrown by the underlying stream
   */
  public AgToken nextGood() throws IOException {
    AgToken r;
    do r = next(false); while (r != null && !r.isGood());
    return r;
  }


  private static boolean isIdFirstCharacter(char c) {
    return Character.isLetter(c)
        || c == '_';
  }
  private static boolean isIdCharacter(char c) {
    return isIdFirstCharacter(c)
      || c == '<'
      || c == '>'; // allow generic types
  }
  
  /**
   * For testing. (TODO)
   * 
   * @param args
   */
  public static void main(String[] args) {
  }
}
