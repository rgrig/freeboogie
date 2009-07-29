package astgen;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import com.google.common.base.Preconditions;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;

/**
  Provides a convenient interface for reading a stream of {@code
  T}s.

  Elements are read one by one using the method {@code next}.
  The current position in the stream can be {@code mark}ed. The
  method {@code rewind} goes to the closest previous marked
  position or to the beginning of the stream. The user can also
  remove all marks by saying {@code unmark()}. This will throw
  old tokens to the garbage, thereby eventually freeing up
  memory.
  
  Also, you can define shorthand mappings from one element X to a
  list of elements Y1, ..., Yn. If {@code next(true)} is called
  the expansion is done behind the scenes. This should play well
  with rewind, and any combination of {@code next(false)}, and
  {@code next(true)} should be safe.

  The user of this class should implement the method {@code
  read} which returns elements in order or {@code null} if the
  end-of-file is reached.

  @author rgrig 
  @param <T> the type of the stream elements
 */
public abstract class PeekStream<T extends Token> {
  /*
    We keep a |buffer| of elements that have been returned by
    {@code next} but not yet eaten. These are linked from the
    oldest to the newest, so that wo can re-iterate through them.
    Each element is a pair (token, location). We also keep
    a list of marked elements. This goes from newest to oldest
    and is used like a stack: |mark| does push and |rewind|
    does |pop|.

    Shorthands are remembered in a map from tokens to a list
    of tokens. If |next(true)| is called and the next node is
    a shorthand then it is expanded by copying rhs and tagging
    each with its own location. A pointer to this expansion
    is saved so that it is not repeated in case the user rewinds
    and reads again.
   */

  private static class Node<S> {
    public S data;
    public Node<S> next;
    
    public Node(S data) { this.data = data; }

    public Node(S data, Node<S> next) {
      this.data = data;
      this.next = next;
    }
  }
  
  private static class ElLocPair<T extends Token> {
    public Node<ElLocPair<T>> expansion;
    public T elem;
    public Location<T> loc;
    
    public ElLocPair(T elem, Location<T> loc) {
      this.elem = elem; 
      this.loc = loc;
    }
  }
  
  private static final Logger log = Logger.getLogger("astgen");
  
  private Node<ElLocPair<T>> lastElement; 
  private Node<Node<ElLocPair<T>>> marked;
  private Map<String, List<T>> shorthands = Maps.newHashMap();
  
  private Location<T> initLoc;

  /** Sets {@code initLoc}. */
  public PeekStream(Location<T> loc) { initLoc = loc; }
  public void addShorthand(String t, List<T> e) { shorthands.put(t, e); }

  /**
   * Returns the next element in the stream, or {@code null} if beyond its end. 
   * @return the next element in the stream
   * @throws IOException if thrown by underlying stream
   */
  public T next(boolean expand) throws IOException {
    Node<ElLocPair<T>> nextElement;
    if (lastElement == null || lastElement.next == null) {
      T nextToken = read();
      nextElement = new Node<ElLocPair<T>>(
          new ElLocPair<T>(nextToken, loc().advance(nextToken)));
      if (lastElement != null) lastElement.next = nextElement;
    } else nextElement = lastElement.next;
    lastElement = nextElement;

    List<T> equiv;
    if (expand) {
      while ((equiv = shorthands.get(lastElement.data.elem.rep)) != null) {
        if (lastElement.data.expansion == null) {
          Node<ElLocPair<T>> e = null;
          for (T t : Iterables.reverse(equiv)) {
            e = new Node<ElLocPair<T>>(
                new ElLocPair<T>(t, lastElement.data.loc), e);
          }
          if (e == null) return next(true); // empty expansion
          lastElement.data.expansion = e;
          while (e.next != null) e = e.next;
          e.next = lastElement.next;
        }
        lastElement = lastElement.data.expansion;
      }
    }
    return lastElement.data.elem;
  }
 
  /** Mark the element last returned by {@code next()}. */
  public void mark() {
    marked = new Node<Node<ElLocPair<T>>>(lastElement, marked);
  }
  
  /** Go back to the previously marked element. */
  public void rewind() {
    Preconditions.checkState(marked != null, "There is no marker.");
    lastElement = marked.data;
    marked = marked.next;
  }
 
  public void unmark() { marked = null; }
  
  /** The location of the last thing returned by {@code next()},
      or {@code initLoc} if {@code next()} was not called yet. */
  public Location<T> loc() {
    if (lastElement == null) return initLoc;
    else return lastElement.data.loc;
  }
  
  public String name() { return getClass().getName(); }
  
  /**
   * Reads one element from the underlying stream. Must return {@code null}
   * if the end was reached.
   * @return the next element in the underlying stream
   * @throws IOException if thrown by the underlying stream
   */
  protected abstract T read() throws IOException; 
}
