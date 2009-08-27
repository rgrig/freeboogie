package freeboogie.editor.eclipse;

import org.eclipse.jface.text.rules.IWhitespaceDetector;

public class BoogieWhitespaceDetector implements IWhitespaceDetector {
  public boolean isWhitespace(final char c) {
    return c == ' ' || c == '\t' || c == '\n' || c == '\r';
  }
}
