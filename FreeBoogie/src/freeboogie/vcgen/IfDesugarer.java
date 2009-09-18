package freeboogie.vcgen;

/** Replaces <b>if</b> statements by <b>assume</b> statements.
  The code
    <pre>
    if (C) { Y } else { N }
    </pre>
  becomes
    <pre>
    goto L1, L2;
    L1: assume C;
        Y
        goto L3;
    L2: assume !C;
        N
    L3: assume true;
    </pre>
  
  <p>Note that both Y and N may be empty, and N may be missing
  completely, which is equivalent to being empty. If C is a
  wildcard then the statements at L1 and L2 are both <tt>assume
  true</tt>.

  <p>The <b>if</b> statements in Y and N are processed first.
 */
public class IfDesugarer extends CommandDesugarer {
}
