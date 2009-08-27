package freeboogie.editor.eclipse;

import org.eclipse.jface.text.rules.IPredicateRule;
import org.eclipse.jface.text.rules.RuleBasedPartitionScanner;

public class BoogiePartitionScanner extends RuleBasedPartitionScanner {
	public final static String XML_COMMENT = "__xml_comment";
	public final static String XML_TAG = "__xml_tag";

	public BoogiePartitionScanner() {
		final IPredicateRule[] rules = new IPredicateRule[0];

		setPredicateRules(rules);
	}
}
