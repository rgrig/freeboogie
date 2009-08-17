package freeboogie.backend;

import com.google.common.collect.ImmutableList;

import java.util.HashMap;

/**
 * Builds a term tree, which looks like an S-expression.
 *
 * @author rgrig 
 */
public class SmtTermBuilder extends TermBuilder<SmtTerm> {
  private HashMap<String, SmtTerm> axioms = new HashMap<String, SmtTerm>();

  @Override
  protected SmtTerm reallyMk(Sort sort, String termId, Object a) {
    return SmtTerm.mk(sort, termId, a);
  }

  @Override
  protected SmtTerm reallyMk(Sort sort, String termId, ImmutableList<SmtTerm> a) {
    return SmtTerm.mk(sort, termId, a);
  }

  @Override
  protected SmtTerm reallyMkNary(Sort sort, String termId, ImmutableList<SmtTerm> a) {
    if (termId.equals("and") || termId.equals("or")) {
      boolean id = termId.equals("or") ? false : true;
      ImmutableList.Builder<SmtTerm> children = ImmutableList.builder();
      for (SmtTerm t : a) {
        if (t.id.equals(termId))
          children.addAll(t.children);
        else if (!t.id.equals("literal_formula") || (Boolean)t.data != id)
          children.add(t);
      }
      a = children.build();
      if (a.size() == 1)
        return a.get(0);
      if (a.size() == 0)
        return mk("literal_formula", id);
    }
    return SmtTerm.mk(sort, termId, a);
  }
}
