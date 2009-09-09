procedure p(x : int) returns(y : int) {
  goto a, b;
a:
  assume x % 2 == 0;
  goto c;
b:
  assume x % 2 != 0;
  x := x + 1;
c:
  y := x;
}
