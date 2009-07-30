package astgen;

/**
  Tracks the location of {@code Token}s.
  
  When a {@code Location} object {@code n} is created
  using the default constructor it should point just
  <i>before</i> the beginning of the stream. The location
  {@code n.advance(a).advance(b).advance(c)} should reflect the
  position of element {@code c} given that it is preceded (only
  by) {@code a} and {@code b}.
 
  @author rgrig 
  @param <T> the type of the stream element
 */
public class Location<T extends Token> {
  private static class LineColumn {
    public int line;
    public int column;
    
    public LineColumn(int line, int column) {
      this.line = line;
      this.column = column;
    }
    public LineColumn() { this(1, 1); }
    public LineColumn(LineColumn o) { this(o.line, o.column); }

    public void advance(char c) {
      if (c == '\n') {
        ++line;
        column = 1;
      } else ++column;
    }

    @Override public String toString() { return line + ":" + column; }
  }

  private LineColumn start = new LineColumn();
  private LineColumn stop = new LineColumn();

  public Location<T> advance(T element) {
    // convention: empty elements have start and stop pointing after them
    start = new LineColumn(stop);
    if (element == null) return this;
    String r = element.rep();
    for (int i = 0; i < r.length(); ++i) stop.advance(r.charAt(i));
    return this;
  }
  
  @Override public String toString() { return "[" + start + "," + stop + ")"; }
}
