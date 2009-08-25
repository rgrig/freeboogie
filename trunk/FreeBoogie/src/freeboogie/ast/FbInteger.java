package freeboogie.ast;

import java.math.BigInteger;

/** A Boogie integer. */
public final class FbInteger {
  private BigInteger value;
  private int width; // -1 means unlimited

  public FbInteger(BigInteger value, int width) {
    this.value = value;
    this.width = width;
  }

  public BigInteger value() { return value; }
  public int width() { return width; }

  @Override public String toString() {
    String r =  value.toString();
    if (width >= 0) r += "bv" + width;
    return r;
  }
}
