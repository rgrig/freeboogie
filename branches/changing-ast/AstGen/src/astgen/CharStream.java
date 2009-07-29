package astgen;

import java.io.IOException;
import java.io.InputStream;

/**
 * A character stream.
 * 
 * @author rgrig 
 */
public class CharStream extends PeekStream<Character> {
  private InputStream stream;
  
  public CharStream(InputStream stream) {
    super(new CharLocation());
    this.stream = stream;
  }
  
  public CharStream(InputStream stream, String name) {
    this(stream);
    this.name = name;
  }
  
  /* @see astgen.PeekStream#read() */
  @Override
  public Character read() throws IOException {
    Character r = null;
    int c = stream.read();
    if (c != -1) r = Character.valueOf((char) c);
    return r;
  }
}
