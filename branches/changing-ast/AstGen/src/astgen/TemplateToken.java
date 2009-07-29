package astgen;

import genericutils.Err;

/**
 * Represents a token in a template file.
 *
 * @author rgrig 
 */
public class TemplateToken extends Token {
  
  /** Token types. */
  public static enum Type {
    // In the template, these look similar.
    FILE,
    USER_DEFINE,
    CLASSES,
    IF_ABSTRACT,
    ABSTRACT_CLASSES,
    NORMAL_CLASSES,
    CLASS_NAME,
    BASE_NAME,
    MEMBERS,
    SELFMEMBERS,
    INHERITEDMEMBERS,
    MEMBER_TYPE,
    MEMBER_NAME,
    IF_PRIMITIVE,
    IF_NONNULL,
    IF_ENUM,
    IF_TAGGED,
    CHILDREN,
    PRIMITIVES,
    ENUMS,
    ENUM_NAME,
    VALUES,
    VALUE_NAME,
    INVARIANTS,
    INV,
    DEF,

    // These are symbols in the template.
    LP, // (
    RP, // )
    LB, // [
    RB, // ]
    LC, // {
    RC, // }
    OR, // |
    AND, // &

    OTHER // to be copied verbatim
  }

  /** Case styles for identifiers. */
  public static enum Case {
    /* camelCase */ CAMEL_CASE,
    /* PascalCase */ PASCAL_CASE,
    /* lower_case */ LOWER_CASE,
    /* UPPER_CASE */ UPPER_CASE,
    /* as it appears in the abstract grammar */ ORIGINAL_CASE;

    /** Changes the case of {@code id}. When {@code noOriginal}
     * and this == ORIGINAL_CASE it will output Originalcase. */
    public String convertId(String id, boolean noOriginal) {
      if (this == ORIGINAL_CASE && !noOriginal) return id;
      StringBuilder res = new StringBuilder(id.length());
      boolean first = true;
      boolean prevIs_ = true;
      boolean prevIsUpper = false;
      for (int i = 0; i < id.length(); ++i) {
        char c = id.charAt(i);
        if (c == '_') prevIs_ = true;
        else {
          boolean thisIsUpper = Character.isUpperCase(c);
          if (prevIs_ || (thisIsUpper && !prevIsUpper)) {
            // beginning of word
            switch (this) {
            case CAMEL_CASE:
              if (first) res.append(Character.toLowerCase(c));
              else res.append(Character.toUpperCase(c));
              break;
            case PASCAL_CASE:
              res.append(Character.toUpperCase(c));
              break;
            case LOWER_CASE:
              if (!first) res.append('_');
              res.append(Character.toLowerCase(c));
              break;
            case UPPER_CASE:
              if (!first) res.append('_');
              res.append(Character.toUpperCase(c));
              break;
            case ORIGINAL_CASE:
              if (first) res.append(Character.toUpperCase(c));
              else res.append(Character.toLowerCase(c));
              break;
            default:
              Err.fatal("Don't know which case to use for " + id);
            }
          } else {
            // the rest of letters
            switch (this) {
            case UPPER_CASE:
              res.append(Character.toUpperCase(c));
              break;
            default:
              res.append(Character.toLowerCase(c));
            }
          }
          first = false;
          prevIs_ = false;
          prevIsUpper = thisIsUpper;
        }
      }
      return res.toString();
    }

    public String convertId(String id) {
      return convertId(id, false);
    }
  }

  /** The type of this token. */
  public Type type;
  
  /** 
   * The case of the last macro. 
   * Set and used for CLASS_NAME, BASE_NAME, MEMBER_TYPE, MEMBER_NAME,
   * ENUM_NAME, VALUE_NAME. Otherwise is meaningless.  
   */
  public Case idCase;
  
  /**
   * Initializes a token.
   * @param type the token type
   * @param rep the token representation
   * @param idCase the case convention of the token and of the represented id
   */
  public TemplateToken(Type type, String rep, Case idCase) {
    super(rep);
    this.type = type;
    this.idCase = idCase;
  }
}
