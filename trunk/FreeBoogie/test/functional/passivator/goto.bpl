/* This checks that copy commands are inserted properly after
  a goto command. */
procedure p() returns() {
  var x : int;
  goto a, b, c;
a: goto c;
b: x := 1; goto c, end;
c: x := 1; goto end;
end: return;
}
