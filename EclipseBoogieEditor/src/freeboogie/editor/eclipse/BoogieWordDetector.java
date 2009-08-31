package freeboogie.editor.eclipse;

import org.eclipse.jface.text.rules.IWordDetector;

public class BoogieWordDetector implements IWordDetector {
  private boolean[] wordPart = new boolean[256];
  private boolean[] wordStart = new boolean[256];
  private static final String boogieIdLetters =
      "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM" +
      "'~#$.?_^";
  private static final String boogieIdOnlyStart = "\\";
  private static final String boogieIdOnlyPart = "`0123456789";
  
  public BoogieWordDetector() {
    for (int i = 0; i < boogieIdLetters.length(); ++i) {
      wordPart[boogieIdLetters.charAt(i)] = true;
      wordStart[boogieIdLetters.charAt(i)] = true;
    }
    for (int i = 0; i < boogieIdOnlyStart.length(); ++i) {
      wordStart[boogieIdLetters.charAt(i)] = true;
    }
    for (int i = 0; i < boogieIdOnlyPart.length(); ++i) {
      wordPart[boogieIdLetters.charAt(i)] = true;
    }
  }

  @Override
  public boolean isWordPart(char c) {
  	return wordPart[c];
  }

  @Override
  public boolean isWordStart(char c) {
    return wordStart[c];
  }
}
