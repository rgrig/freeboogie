package astgen;

import java.io.IOException;
import java.io.InputStream;

/**
 * A character stream.
 * 
 * @author rgrig 
 */
public class CharStream extends PeekStream<CharToken> {
  private String name;
  private InputStream stream;
  
  public CharStream(InputStream stream) {
    this.stream = stream;
  }
  
  public CharStream(InputStream stream, String name) {
    this(stream);
    this.name = name;
  }
  
  @Override public CharToken read() throws IOException {
    CharToken r = null;
    int c = stream.read();
    if (c != -1) r = new CharToken(c);
    return r;
  }

  @Override public String name() { return name; }
}
