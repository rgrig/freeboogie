axiom (forall x : int :: x % 2 == 0 || (x + 1) % 2 == 0);

// Break with label.
procedure p(x : int) returns(y : int) 
  ensures y % 2 == 0;
{
  if (x % 2 == 0) {
    break foo;
  }
  y := x + 1;
  return;
foo:
  y := x;
}
