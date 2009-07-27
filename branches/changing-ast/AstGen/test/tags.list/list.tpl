vim:ft=java:

In this template we implement the Composite pattern for
an AST that has members tagged as lists.

\file{/dev/stdout}

\normal_classes{
  class \ClassName extends \BaseName {
    // === memeber declarations ===
    \members{
      \if_tagged{list}{
        private final List<\if_primitive{\MemberType}{\MemberType}> \memberName;
      }{
        private final \if_primitive{\Membertype}{\MemberType} \memberName;
      }
    }

    // === construction ===
    public \ClassName(
      \members[,]{
        \if_primitive{\Membertype}{\MemberType} \memberName
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
          r += this.\memberName.size();
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
          if (index < this.\memberName.size()) 
            return this.\memberName.get(index);
          else index -= this.\memberName.size();
        }{
          if (index == 0) return this.\memberName;
          else --index;
        }
      }
      assert false : "index is too big";
      return null;
    }
  }
}
