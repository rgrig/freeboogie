vim:ft=java:

In this template we implement the Composite pattern for
an AST that has members tagged as lists.

\file{/dev/stdout}

\normal_classes{
  class \ClassName extends \BaseName {
    // === memeber declarations ===
    \children{
      \if_tagged{list}{
        private final List<\MemberType> \memberName;
      }{
        private final \MemberType \memberName;
      }
    }
    \primitives{
      private final \Membertype \memberName;
    }

    // === construction ===
    public \ClassName(
      \members[,]{
        \if_primitive{\Membertype}{\memberType} \memberName
      }
    ) {
      \members{
        \if_tagged{nonnull|list}{assert \memberName != null;}{}
        this.\memberName = \memberName;
      }
    }

    // === read-only accessors ===
    \members{
      public \if_primitive{\Membertype}{\MemberType} \memberName() {
        return \memberName;
      }
    }

    // === the Composite pattern ===
    public int length() {
      int r = 0;
      \children{
        \if_tagged{list}{
          r += \memberName.size();
        }{
          ++r;
        }
      }
      return r;
    }

    public Ast child(int index) {
      assert 0 <= index;
      \children{
        \if_tagged{list}{
          if (index < \memberName.size()) return \memberName.get(index);
          else index -= \memberName.size();
        }{
          if (index == 0) return \memberName;
          else --index;
        }
      }
      assert false : "index is too big";
      return null;
    }
  }
}
