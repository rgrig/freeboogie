package astgen;

public class CharToken implements Token {
  private char c;

  public CharToken(char c) { this.c = c; }
  public CharToken(int c) { this((char) c); }

  @Override public String rep() { return String.valueOf(c); }
  public char c() { return c; }
}
