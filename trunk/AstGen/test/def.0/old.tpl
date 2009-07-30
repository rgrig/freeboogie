vim:ft=java:

Playing with user shorthands.

\file{/dev/stdout}
\def{x}{
  boo
}
\x
\def{mt}{\if_primitive{\member_type}{\MEMBER_TYPE}}
\def{defprint}{
  \def{print}{
    \normal_classes{
      \ClassName: \members[, ]{\mt \memberName};}}}
\defprint
\print
\def{mt}{\if_tagged{list}{List<}{}\if_primitive{\member_type}{\MEMBER_TYPE}\if_tagged{list}{>}{}}
\defprint
\print
