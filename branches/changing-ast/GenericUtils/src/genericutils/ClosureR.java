package genericutils;

/**
 * For functions that take {@code P} and return {@code R}.
 * DEPRECATED: Use com.google.common.base.Function instead.
 *
 * @author rgrig 
 * @param <P> the type of the parameter
 * @param <R> teh type of the result
 */
@Deprecated
public abstract class ClosureR<P, R> {
  /**
   * Process {@code p}.
   * @param p what to process
   * @return whatever you want
   */
  public abstract R go(P p);
}
