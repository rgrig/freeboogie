package astgen;

/**
 * Represents a token in a template file.
 *
 * @author rgrig 
 */
public class TemplateToken extends Token {
  
  /** Token types. */
  public enum Type {
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
    IF_TERMINAL,
    CHILDREN,
    PRIMITIVES,
    ENUMS,
    ENUM_NAME,
    VALUES,
    VALUE_NAME,
    INVARIANTS,
    INV,

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
  public enum Case {
    /* camelCase */ CAMEL_CASE,
    /* PascalCase */ PASCAL_CASE,
    /* lower_case */ LOWER_CASE,
    /* UPPER_CASE */ UPPER_CASE,
    /* as it appears in the abstract grammar */ ORIGINAL_CASE
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
