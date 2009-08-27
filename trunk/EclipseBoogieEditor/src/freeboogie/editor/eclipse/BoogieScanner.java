package freeboogie.editor.eclipse;

import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.rules.EndOfLineRule;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.RuleBasedScanner;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.jface.text.rules.WhitespaceRule;
import org.eclipse.jface.text.rules.WordRule;
import org.eclipse.swt.graphics.RGB;

public class BoogieScanner extends RuleBasedScanner {
  private static final String[] boogieKeywords = {
    "while",
    "assert",
    "assume",
    "axiom",
    "bool",
    "break",
    "call",
    "cast",
    "const",
    "else",
    "ensures",
    "exists",
    "false",
    "finite",
    "forall",
    "free",
    "function",
    "goto",
    "havoc",
    "if",
    "implementation",
    "int",
    "modifies",
    "old",
    "procedure",
    "requires",
    "return",
    "returns",
    "true",
    "type",
    "unique",
    "var",
    "where",
    "while"
  };
  
  final RGB[] tokenTypeColor = {
      IBoogieColorConstants.KEYWORD,
      IBoogieColorConstants.COMMENT
  };
  
  final IToken[] tokenType = new IToken[tokenTypeColor.length];
  
  public BoogieScanner(final ColorManager manager) {
    for (int i = 0; i < tokenType.length; ++i) {
      tokenType[i] = new Token(new TextAttribute(manager.getColor(
          tokenTypeColor[i])));
    }

    final IRule[] rules = new IRule[3];
    final WordRule keywords = new WordRule(new BoogieWordDetector());
    for (String kw : boogieKeywords) {
      keywords.addWord(kw, tokenType[0]);
    }
    rules[0] = keywords;
    rules[1] = new WhitespaceRule(new BoogieWhitespaceDetector());
    rules[2] = new EndOfLineRule("//", tokenType[1]);
    
    setRules(rules);
  }
}
