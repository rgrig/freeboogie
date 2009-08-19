// Spec# program verifier version 2.00, Copyright (c) 2003-2008, Microsoft.
// Command Line Options: ArrayList.exe /print:ArrayList.bpl

type TName;

type real;

type Elements _;

type struct;

const $ZeroStruct: struct;

type ref;

const null: ref;

type Field _;

type HeapType = <beta>[ref,Field beta]beta;

var $Heap: HeapType where IsHeap($Heap);

type ActivityType;

var $ActivityIndicator: ActivityType;

function IsHeap(h: HeapType) returns (bool);

const unique $allocated: Field bool;

const unique $elementsBool: Field (Elements bool);

const unique $elementsInt: Field (Elements int);

const unique $elementsRef: Field (Elements ref);

const unique $elementsReal: Field (Elements real);

const unique $elementsStruct: Field (Elements struct);

axiom DeclType($elementsBool) == System.Array;

axiom DeclType($elementsInt) == System.Array;

axiom DeclType($elementsRef) == System.Array;

axiom DeclType($elementsReal) == System.Array;

axiom DeclType($elementsStruct) == System.Array;

const unique $inv: Field TName;

const unique $localinv: Field TName;

type exposeVersionType;

const unique $exposeVersion: Field exposeVersionType;

axiom DeclType($exposeVersion) == System.Object;

type SharingMode;

const unique $sharingMode: Field SharingMode;

const unique $SharingMode_Unshared: SharingMode;

const unique $SharingMode_LockProtected: SharingMode;

const unique $ownerRef: Field ref;

const unique $ownerFrame: Field TName;

const unique $PeerGroupPlaceholder: TName;

function ClassRepr(class: TName) returns (ref);

function ClassReprInv(ref) returns (TName);

axiom (forall c: TName :: { ClassRepr(c) } ClassReprInv(ClassRepr(c)) == c);

axiom (forall T: TName :: !($typeof(ClassRepr(T)) <: System.Object));

axiom (forall T: TName :: ClassRepr(T) != null);

axiom (forall T: TName, h: HeapType :: { h[ClassRepr(T), $ownerFrame] } IsHeap(h) ==> h[ClassRepr(T), $ownerFrame] == $PeerGroupPlaceholder);

function IncludeInMainFrameCondition<alpha>(f: Field alpha) returns (bool);

axiom IncludeInMainFrameCondition($allocated);

axiom IncludeInMainFrameCondition($elementsBool) && IncludeInMainFrameCondition($elementsInt) && IncludeInMainFrameCondition($elementsRef) && IncludeInMainFrameCondition($elementsReal) && IncludeInMainFrameCondition($elementsStruct);

axiom !IncludeInMainFrameCondition($inv);

axiom !IncludeInMainFrameCondition($localinv);

axiom IncludeInMainFrameCondition($ownerRef);

axiom IncludeInMainFrameCondition($ownerFrame);

axiom IncludeInMainFrameCondition($exposeVersion);

axiom !IncludeInMainFrameCondition($FirstConsistentOwner);

function IsStaticField<alpha>(f: Field alpha) returns (bool);

axiom !IsStaticField($allocated);

axiom !IsStaticField($elementsBool) && !IsStaticField($elementsInt) && !IsStaticField($elementsRef) && !IsStaticField($elementsReal) && !IsStaticField($elementsStruct);

axiom !IsStaticField($inv);

axiom !IsStaticField($localinv);

axiom !IsStaticField($exposeVersion);

function $IncludedInModifiesStar<alpha>(f: Field alpha) returns (bool);

axiom !$IncludedInModifiesStar($ownerRef);

axiom !$IncludedInModifiesStar($ownerFrame);

axiom $IncludedInModifiesStar($exposeVersion);

axiom $IncludedInModifiesStar($elementsBool) && $IncludedInModifiesStar($elementsInt) && $IncludedInModifiesStar($elementsRef) && $IncludedInModifiesStar($elementsReal) && $IncludedInModifiesStar($elementsStruct);

function ArrayGet<alpha>(Elements alpha, int) returns (alpha);

function ArraySet<alpha>(Elements alpha, int, alpha) returns (Elements alpha);

axiom (forall<alpha> A: Elements alpha, i: int, x: alpha :: ArrayGet(ArraySet(A, i, x), i) == x);

axiom (forall<alpha> A: Elements alpha, i: int, j: int, x: alpha :: i != j ==> ArrayGet(ArraySet(A, i, x), j) == ArrayGet(A, j));

function ArrayIndex(arr: ref, dim: int, indexAtDim: int, remainingIndexContribution: int) returns (int);

function ArrayIndexInvX(arrayIndex: int) returns (indexAtDim: int);

function ArrayIndexInvY(arrayIndex: int) returns (remainingIndexContribution: int);

axiom (forall a: ref, d: int, x: int, y: int :: { ArrayIndex(a, d, x, y) } ArrayIndexInvX(ArrayIndex(a, d, x, y)) == x);

axiom (forall a: ref, d: int, x: int, y: int :: { ArrayIndex(a, d, x, y) } ArrayIndexInvY(ArrayIndex(a, d, x, y)) == y);

axiom (forall a: ref, i: int, heap: HeapType :: { ArrayGet(heap[a, $elementsInt], i) } IsHeap(heap) ==> InRange(ArrayGet(heap[a, $elementsInt], i), $ElementType($typeof(a))));

axiom (forall a: ref, i: int, heap: HeapType :: { $typeof(ArrayGet(heap[a, $elementsRef], i)) } IsHeap(heap) && ArrayGet(heap[a, $elementsRef], i) != null ==> $typeof(ArrayGet(heap[a, $elementsRef], i)) <: $ElementType($typeof(a)));

axiom (forall a: ref, T: TName, i: int, r: int, heap: HeapType :: { $typeof(a) <: NonNullRefArray(T, r), ArrayGet(heap[a, $elementsRef], i) } IsHeap(heap) && $typeof(a) <: NonNullRefArray(T, r) ==> ArrayGet(heap[a, $elementsRef], i) != null);

function $Rank(ref) returns (int);

axiom (forall a: ref :: 1 <= $Rank(a));

axiom (forall a: ref, T: TName, r: int :: { $typeof(a) <: RefArray(T, r) } a != null && $typeof(a) <: RefArray(T, r) ==> $Rank(a) == r);

axiom (forall a: ref, T: TName, r: int :: { $typeof(a) <: NonNullRefArray(T, r) } a != null && $typeof(a) <: NonNullRefArray(T, r) ==> $Rank(a) == r);

axiom (forall a: ref, T: TName, r: int :: { $typeof(a) <: ValueArray(T, r) } a != null && $typeof(a) <: ValueArray(T, r) ==> $Rank(a) == r);

axiom (forall a: ref, T: TName, r: int :: { $typeof(a) <: IntArray(T, r) } a != null && $typeof(a) <: IntArray(T, r) ==> $Rank(a) == r);

function $Length(ref) returns (int);

axiom (forall a: ref :: { $Length(a) } 0 <= $Length(a) && $Length(a) <= 2147483647);

function $DimLength(ref, int) returns (int);

axiom (forall a: ref, i: int :: 0 <= $DimLength(a, i));

axiom (forall a: ref :: { $DimLength(a, 0) } $Rank(a) == 1 ==> $DimLength(a, 0) == $Length(a));

function $LBound(ref, int) returns (int);

function $UBound(ref, int) returns (int);

axiom (forall a: ref, i: int :: { $LBound(a, i) } $LBound(a, i) == 0);

axiom (forall a: ref, i: int :: { $UBound(a, i) } $UBound(a, i) == $DimLength(a, i) - 1);

type ArrayCategory;

const unique $ArrayCategoryValue: ArrayCategory;

const unique $ArrayCategoryInt: ArrayCategory;

const unique $ArrayCategoryRef: ArrayCategory;

const unique $ArrayCategoryNonNullRef: ArrayCategory;

function $ArrayCategory(arrayType: TName) returns (arrayCategory: ArrayCategory);

axiom (forall T: TName, ET: TName, r: int :: { T <: ValueArray(ET, r) } T <: ValueArray(ET, r) ==> $ArrayCategory(T) == $ArrayCategoryValue);

axiom (forall T: TName, ET: TName, r: int :: { T <: IntArray(ET, r) } T <: IntArray(ET, r) ==> $ArrayCategory(T) == $ArrayCategoryInt);

axiom (forall T: TName, ET: TName, r: int :: { T <: RefArray(ET, r) } T <: RefArray(ET, r) ==> $ArrayCategory(T) == $ArrayCategoryRef);

axiom (forall T: TName, ET: TName, r: int :: { T <: NonNullRefArray(ET, r) } T <: NonNullRefArray(ET, r) ==> $ArrayCategory(T) == $ArrayCategoryNonNullRef);

const unique System.Array: TName;

axiom System.Array <: System.Object;

function $ElementType(TName) returns (TName);

function ValueArray(elementType: TName, rank: int) returns (TName);

axiom (forall T: TName, r: int :: { ValueArray(T, r) } ValueArray(T, r) <: ValueArray(T, r) && ValueArray(T, r) <: System.Array);

function IntArray(elementType: TName, rank: int) returns (TName);

axiom (forall T: TName, r: int :: { IntArray(T, r) } IntArray(T, r) <: IntArray(T, r) && IntArray(T, r) <: System.Array);

function RefArray(elementType: TName, rank: int) returns (TName);

axiom (forall T: TName, r: int :: { RefArray(T, r) } RefArray(T, r) <: RefArray(T, r) && RefArray(T, r) <: System.Array);

function NonNullRefArray(elementType: TName, rank: int) returns (TName);

axiom (forall T: TName, r: int :: { NonNullRefArray(T, r) } NonNullRefArray(T, r) <: NonNullRefArray(T, r) && NonNullRefArray(T, r) <: System.Array);

function NonNullRefArrayRaw(array: ref, elementType: TName, rank: int) returns (bool);

axiom (forall array: ref, elementType: TName, rank: int :: { NonNullRefArrayRaw(array, elementType, rank) } NonNullRefArrayRaw(array, elementType, rank) ==> $typeof(array) <: System.Array && $Rank(array) == rank && elementType <: $ElementType($typeof(array)));

axiom (forall T: TName, U: TName, r: int :: U <: T ==> RefArray(U, r) <: RefArray(T, r));

axiom (forall T: TName, U: TName, r: int :: U <: T ==> NonNullRefArray(U, r) <: NonNullRefArray(T, r));

axiom (forall A: TName, r: int :: $ElementType(ValueArray(A, r)) == A);

axiom (forall A: TName, r: int :: $ElementType(IntArray(A, r)) == A);

axiom (forall A: TName, r: int :: $ElementType(RefArray(A, r)) == A);

axiom (forall A: TName, r: int :: $ElementType(NonNullRefArray(A, r)) == A);

axiom (forall A: TName, r: int, T: TName :: { T <: RefArray(A, r) } T <: RefArray(A, r) ==> T != A && T == RefArray($ElementType(T), r) && $ElementType(T) <: A);

axiom (forall A: TName, r: int, T: TName :: { T <: NonNullRefArray(A, r) } T <: NonNullRefArray(A, r) ==> T != A && T == NonNullRefArray($ElementType(T), r) && $ElementType(T) <: A);

axiom (forall A: TName, r: int, T: TName :: { T <: ValueArray(A, r) } T <: ValueArray(A, r) ==> T == ValueArray(A, r));

axiom (forall A: TName, r: int, T: TName :: { T <: IntArray(A, r) } T <: IntArray(A, r) ==> T == IntArray(A, r));

axiom (forall A: TName, r: int, T: TName :: { RefArray(A, r) <: T } RefArray(A, r) <: T ==> System.Array <: T || (T == RefArray($ElementType(T), r) && A <: $ElementType(T)));

axiom (forall A: TName, r: int, T: TName :: { NonNullRefArray(A, r) <: T } NonNullRefArray(A, r) <: T ==> System.Array <: T || (T == NonNullRefArray($ElementType(T), r) && A <: $ElementType(T)));

axiom (forall A: TName, r: int, T: TName :: { ValueArray(A, r) <: T } ValueArray(A, r) <: T ==> System.Array <: T || T == ValueArray(A, r));

axiom (forall A: TName, r: int, T: TName :: { IntArray(A, r) <: T } IntArray(A, r) <: T ==> System.Array <: T || T == IntArray(A, r));

function $ArrayPtr(elementType: TName) returns (TName);

function $ElementProxy(ref, int) returns (ref);

function $ElementProxyStruct(struct, int) returns (ref);

axiom (forall a: ref, i: int, heap: HeapType :: { heap[ArrayGet(heap[a, $elementsRef], i), $ownerRef] } { heap[ArrayGet(heap[a, $elementsRef], i), $ownerFrame] } IsHeap(heap) && $typeof(a) <: System.Array ==> ArrayGet(heap[a, $elementsRef], i) == null || $IsImmutable($typeof(ArrayGet(heap[a, $elementsRef], i))) || (heap[ArrayGet(heap[a, $elementsRef], i), $ownerRef] == heap[$ElementProxy(a, 0 - 1), $ownerRef] && heap[ArrayGet(heap[a, $elementsRef], i), $ownerFrame] == heap[$ElementProxy(a, 0 - 1), $ownerFrame]));

axiom (forall a: ref, heap: HeapType :: { IsAllocated(heap, a) } IsHeap(heap) && IsAllocated(heap, a) && $typeof(a) <: System.Array ==> IsAllocated(heap, $ElementProxy(a, 0 - 1)));

axiom (forall o: ref, pos: int :: { $typeof($ElementProxy(o, pos)) } $typeof($ElementProxy(o, pos)) == System.Object);

axiom (forall o: struct, pos: int :: { $typeof($ElementProxyStruct(o, pos)) } $typeof($ElementProxyStruct(o, pos)) == System.Object);

function $StructGet<alpha>(struct, Field alpha) returns (alpha);

function $StructSet<alpha>(struct, Field alpha, alpha) returns (struct);

axiom (forall<alpha> s: struct, f: Field alpha, x: alpha :: $StructGet($StructSet(s, f, x), f) == x);

axiom (forall<alpha,beta> s: struct, f: Field alpha, f': Field beta, x: alpha :: f != f' ==> $StructGet($StructSet(s, f, x), f') == $StructGet(s, f'));

function ZeroInit(s: struct, typ: TName) returns (bool);

function $typeof(ref) returns (TName);

function $BaseClass(sub: TName) returns (base: TName);

axiom (forall T: TName :: { $BaseClass(T) } T <: $BaseClass(T) && (T != System.Object ==> T != $BaseClass(T)));

function AsDirectSubClass(sub: TName, base: TName) returns (sub': TName);

function OneClassDown(sub: TName, base: TName) returns (directSub: TName);

axiom (forall A: TName, B: TName, C: TName :: { C <: AsDirectSubClass(B, A) } C <: AsDirectSubClass(B, A) ==> OneClassDown(C, A) == B);

function $IsValueType(TName) returns (bool);

axiom (forall T: TName :: $IsValueType(T) ==> (forall U: TName :: T <: U ==> T == U) && (forall U: TName :: U <: T ==> T == U));

const unique System.Boolean: TName;

axiom $IsValueType(System.Boolean);

const unique System.Object: TName;

function $IsTokenForType(struct, TName) returns (bool);

function TypeObject(TName) returns (ref);

const unique System.Type: TName;

axiom System.Type <: System.Object;

axiom (forall T: TName :: { TypeObject(T) } $IsNotNull(TypeObject(T), System.Type));

function TypeName(ref) returns (TName);

axiom (forall T: TName :: { TypeObject(T) } TypeName(TypeObject(T)) == T);

function $Is(ref, TName) returns (bool);

axiom (forall o: ref, T: TName :: { $Is(o, T) } $Is(o, T) <==> o == null || $typeof(o) <: T);

function $IsNotNull(ref, TName) returns (bool);

axiom (forall o: ref, T: TName :: { $IsNotNull(o, T) } $IsNotNull(o, T) <==> o != null && $Is(o, T));

function $As(ref, TName) returns (ref);

axiom (forall o: ref, T: TName :: $Is(o, T) ==> $As(o, T) == o);

axiom (forall o: ref, T: TName :: !$Is(o, T) ==> $As(o, T) == null);

axiom (forall h: HeapType, o: ref :: { $typeof(o) <: System.Array, h[o, $inv] } IsHeap(h) && o != null && $typeof(o) <: System.Array ==> h[o, $inv] == $typeof(o) && h[o, $localinv] == $typeof(o));

function IsAllocated<alpha>(h: HeapType, o: alpha) returns (bool);

axiom (forall<alpha> h: HeapType, o: ref, f: Field alpha :: { IsAllocated(h, h[o, f]) } IsHeap(h) && h[o, $allocated] ==> IsAllocated(h, h[o, f]));

axiom (forall h: HeapType, o: ref, f: Field ref :: { h[h[o, f], $allocated] } IsHeap(h) && h[o, $allocated] ==> h[h[o, f], $allocated]);

axiom (forall<alpha> h: HeapType, s: struct, f: Field alpha :: { IsAllocated(h, $StructGet(s, f)) } IsAllocated(h, s) ==> IsAllocated(h, $StructGet(s, f)));

axiom (forall<alpha> h: HeapType, e: Elements alpha, i: int :: { IsAllocated(h, ArrayGet(e, i)) } IsAllocated(h, e) ==> IsAllocated(h, ArrayGet(e, i)));

axiom (forall h: HeapType, o: ref :: { h[o, $allocated] } IsAllocated(h, o) ==> h[o, $allocated]);

axiom (forall h: HeapType, c: TName :: { h[ClassRepr(c), $allocated] } IsHeap(h) ==> h[ClassRepr(c), $allocated]);

const $BeingConstructed: ref;

const unique $NonNullFieldsAreInitialized: Field bool;

const $PurityAxiomsCanBeAssumed: bool;

axiom DeclType($NonNullFieldsAreInitialized) == System.Object;

function DeclType<alpha>(field: Field alpha) returns (class: TName);

function AsNonNullRefField(field: Field ref, T: TName) returns (f: Field ref);

function AsRefField(field: Field ref, T: TName) returns (f: Field ref);

function AsRangeField(field: Field int, T: TName) returns (f: Field int);

axiom (forall f: Field ref, T: TName :: { AsNonNullRefField(f, T) } AsNonNullRefField(f, T) == f ==> AsRefField(f, T) == f);

axiom (forall h: HeapType, o: ref, f: Field ref, T: TName :: { h[o, AsRefField(f, T)] } IsHeap(h) ==> $Is(h[o, AsRefField(f, T)], T));

axiom (forall h: HeapType, o: ref, f: Field ref, T: TName :: { h[o, AsNonNullRefField(f, T)] } IsHeap(h) && o != null && (o != $BeingConstructed || h[$BeingConstructed, $NonNullFieldsAreInitialized] == true) ==> h[o, AsNonNullRefField(f, T)] != null);

axiom (forall h: HeapType, o: ref, f: Field int, T: TName :: { h[o, AsRangeField(f, T)] } IsHeap(h) ==> InRange(h[o, AsRangeField(f, T)], T));

function $IsMemberlessType(TName) returns (bool);

axiom (forall o: ref :: { $IsMemberlessType($typeof(o)) } !$IsMemberlessType($typeof(o)));

function $AsInterface(TName) returns (TName);

axiom (forall J: TName :: { System.Object <: $AsInterface(J) } $AsInterface(J) == J ==> !(System.Object <: J));

axiom (forall<T> $J: TName, s: T, b: ref :: { UnboxedType(Box(s, b)) <: $AsInterface($J) } $AsInterface($J) == $J && Box(s, b) == b && UnboxedType(Box(s, b)) <: $AsInterface($J) ==> $typeof(b) <: $J);

function $HeapSucc(oldHeap: HeapType, newHeap: HeapType) returns (bool);

function $IsImmutable(T: TName) returns (bool);

axiom !$IsImmutable(System.Object);

function $AsImmutable(T: TName) returns (theType: TName);

function $AsMutable(T: TName) returns (theType: TName);

axiom (forall T: TName, U: TName :: { U <: $AsImmutable(T) } U <: $AsImmutable(T) ==> $IsImmutable(U) && $AsImmutable(U) == U);

axiom (forall T: TName, U: TName :: { U <: $AsMutable(T) } U <: $AsMutable(T) ==> !$IsImmutable(U) && $AsMutable(U) == U);

function AsOwner(string: ref, owner: ref) returns (theString: ref);

axiom (forall o: ref, T: TName :: { $typeof(o) <: $AsImmutable(T) } o != null && o != $BeingConstructed && $typeof(o) <: $AsImmutable(T) ==> (forall h: HeapType :: { IsHeap(h) } IsHeap(h) ==> h[o, $inv] == $typeof(o) && h[o, $localinv] == $typeof(o) && h[o, $ownerFrame] == $PeerGroupPlaceholder && AsOwner(o, h[o, $ownerRef]) == o && (forall t: ref :: { AsOwner(o, h[t, $ownerRef]) } AsOwner(o, h[t, $ownerRef]) == o ==> t == o || h[t, $ownerFrame] != $PeerGroupPlaceholder)));

const unique System.String: TName;

function $StringLength(ref) returns (int);

axiom (forall s: ref :: { $StringLength(s) } 0 <= $StringLength(s));

function AsRepField(f: Field ref, declaringType: TName) returns (theField: Field ref);

axiom (forall h: HeapType, o: ref, f: Field ref, T: TName :: { h[o, AsRepField(f, T)] } IsHeap(h) && h[o, AsRepField(f, T)] != null ==> h[h[o, AsRepField(f, T)], $ownerRef] == o && h[h[o, AsRepField(f, T)], $ownerFrame] == T);

function AsPeerField(f: Field ref) returns (theField: Field ref);

axiom (forall h: HeapType, o: ref, f: Field ref :: { h[o, AsPeerField(f)] } IsHeap(h) && h[o, AsPeerField(f)] != null ==> h[h[o, AsPeerField(f)], $ownerRef] == h[o, $ownerRef] && h[h[o, AsPeerField(f)], $ownerFrame] == h[o, $ownerFrame]);

function AsElementsRepField(f: Field ref, declaringType: TName, position: int) returns (theField: Field ref);

axiom (forall h: HeapType, o: ref, f: Field ref, T: TName, i: int :: { h[o, AsElementsRepField(f, T, i)] } IsHeap(h) && h[o, AsElementsRepField(f, T, i)] != null ==> h[$ElementProxy(h[o, AsElementsRepField(f, T, i)], i), $ownerRef] == o && h[$ElementProxy(h[o, AsElementsRepField(f, T, i)], i), $ownerFrame] == T);

function AsElementsPeerField(f: Field ref, position: int) returns (theField: Field ref);

axiom (forall h: HeapType, o: ref, f: Field ref, i: int :: { h[o, AsElementsPeerField(f, i)] } IsHeap(h) && h[o, AsElementsPeerField(f, i)] != null ==> h[$ElementProxy(h[o, AsElementsPeerField(f, i)], i), $ownerRef] == h[o, $ownerRef] && h[$ElementProxy(h[o, AsElementsPeerField(f, i)], i), $ownerFrame] == h[o, $ownerFrame]);

axiom (forall h: HeapType, o: ref :: { h[h[o, $ownerRef], $inv] <: h[o, $ownerFrame] } IsHeap(h) && h[o, $ownerFrame] != $PeerGroupPlaceholder && h[h[o, $ownerRef], $inv] <: h[o, $ownerFrame] && h[h[o, $ownerRef], $localinv] != $BaseClass(h[o, $ownerFrame]) ==> h[o, $inv] == $typeof(o) && h[o, $localinv] == $typeof(o));

procedure $SetOwner(o: ref, ow: ref, fr: TName);
  modifies $Heap;
  ensures (forall<alpha> p: ref, F: Field alpha :: { $Heap[p, F] } (F != $ownerRef && F != $ownerFrame) || old($Heap[p, $ownerRef] != $Heap[o, $ownerRef]) || old($Heap[p, $ownerFrame] != $Heap[o, $ownerFrame]) ==> old($Heap[p, F]) == $Heap[p, F]);
  ensures (forall p: ref :: { $Heap[p, $ownerRef] } { $Heap[p, $ownerFrame] } old($Heap[p, $ownerRef] == $Heap[o, $ownerRef]) && old($Heap[p, $ownerFrame] == $Heap[o, $ownerFrame]) ==> $Heap[p, $ownerRef] == ow && $Heap[p, $ownerFrame] == fr);
  free ensures $HeapSucc(old($Heap), $Heap);



procedure $UpdateOwnersForRep(o: ref, T: TName, e: ref);
  modifies $Heap;
  ensures (forall<alpha> p: ref, F: Field alpha :: { $Heap[p, F] } (F != $ownerRef && F != $ownerFrame) || old($Heap[p, $ownerRef] != $Heap[e, $ownerRef]) || old($Heap[p, $ownerFrame] != $Heap[e, $ownerFrame]) ==> old($Heap[p, F]) == $Heap[p, F]);
  ensures e == null ==> $Heap == old($Heap);
  ensures e != null ==> (forall p: ref :: { $Heap[p, $ownerRef] } { $Heap[p, $ownerFrame] } old($Heap[p, $ownerRef] == $Heap[e, $ownerRef]) && old($Heap[p, $ownerFrame] == $Heap[e, $ownerFrame]) ==> $Heap[p, $ownerRef] == o && $Heap[p, $ownerFrame] == T);
  free ensures $HeapSucc(old($Heap), $Heap);



procedure $UpdateOwnersForPeer(c: ref, d: ref);
  modifies $Heap;
  ensures (forall<alpha> p: ref, F: Field alpha :: { $Heap[p, F] } (F != $ownerRef && F != $ownerFrame) || old($Heap[p, $ownerRef] != $Heap[d, $ownerRef] || $Heap[p, $ownerFrame] != $Heap[d, $ownerFrame]) ==> old($Heap[p, F]) == $Heap[p, F]);
  ensures d == null ==> $Heap == old($Heap);
  ensures d != null ==> (forall p: ref :: { $Heap[p, $ownerRef] } { $Heap[p, $ownerFrame] } old($Heap[p, $ownerRef] == $Heap[d, $ownerRef] && $Heap[p, $ownerFrame] == $Heap[d, $ownerFrame]) ==> $Heap[p, $ownerRef] == old($Heap)[c, $ownerRef] && $Heap[p, $ownerFrame] == old($Heap)[c, $ownerFrame]);
  free ensures $HeapSucc(old($Heap), $Heap);



const unique $FirstConsistentOwner: Field ref;

function $AsPureObject(ref) returns (ref);

function ##FieldDependsOnFCO<alpha>(o: ref, f: Field alpha, ev: exposeVersionType) returns (exposeVersionType);

axiom (forall<alpha> o: ref, f: Field alpha, h: HeapType :: { h[$AsPureObject(o), f] } IsHeap(h) && o != null && h[o, $allocated] == true && $AsPureObject(o) == o && h[o, $ownerFrame] != $PeerGroupPlaceholder && h[h[o, $ownerRef], $inv] <: h[o, $ownerFrame] && h[h[o, $ownerRef], $localinv] != $BaseClass(h[o, $ownerFrame]) ==> h[o, f] == ##FieldDependsOnFCO(o, f, h[h[o, $FirstConsistentOwner], $exposeVersion]));

axiom (forall o: ref, h: HeapType :: { h[o, $FirstConsistentOwner] } IsHeap(h) && o != null && h[o, $allocated] == true && h[o, $ownerFrame] != $PeerGroupPlaceholder && h[h[o, $ownerRef], $inv] <: h[o, $ownerFrame] && h[h[o, $ownerRef], $localinv] != $BaseClass(h[o, $ownerFrame]) ==> h[o, $FirstConsistentOwner] != null && h[h[o, $FirstConsistentOwner], $allocated] == true && (h[h[o, $FirstConsistentOwner], $ownerFrame] == $PeerGroupPlaceholder || !(h[h[h[o, $FirstConsistentOwner], $ownerRef], $inv] <: h[h[o, $FirstConsistentOwner], $ownerFrame]) || h[h[h[o, $FirstConsistentOwner], $ownerRef], $localinv] == $BaseClass(h[h[o, $FirstConsistentOwner], $ownerFrame])));

function Box<T>(T, ref) returns (ref);

function Unbox<T>(ref) returns (T);

type NondetType;

function MeldNondets<a>(NondetType, a) returns (NondetType);

function BoxFunc<T>(value: T, typ: TName) returns (boxedValue: ref);

function AllocFunc(typ: TName) returns (newValue: ref);

function NewInstance(object: ref, occurrence: NondetType, activity: ActivityType) returns (newInstance: ref);

axiom (forall<T> value: T, typ: TName, occurrence: NondetType, activity: ActivityType :: { NewInstance(BoxFunc(value, typ), occurrence, activity) } Box(value, NewInstance(BoxFunc(value, typ), occurrence, activity)) == NewInstance(BoxFunc(value, typ), occurrence, activity) && UnboxedType(NewInstance(BoxFunc(value, typ), occurrence, activity)) == typ);

axiom (forall x: ref, typ: TName, occurrence: NondetType, activity: ActivityType :: !$IsValueType(UnboxedType(x)) ==> NewInstance(BoxFunc(x, typ), occurrence, activity) == x);

axiom (forall<T> x: T, p: ref :: { Unbox(Box(x, p)):T } Unbox(Box(x, p)) == x);

function UnboxedType(ref) returns (TName);

axiom (forall p: ref :: { $IsValueType(UnboxedType(p)) } $IsValueType(UnboxedType(p)) ==> (forall<T> heap: HeapType, x: T :: { heap[Box(x, p), $inv] } IsHeap(heap) ==> heap[Box(x, p), $inv] == $typeof(Box(x, p)) && heap[Box(x, p), $localinv] == $typeof(Box(x, p))));

axiom (forall<T> x: T, p: ref :: { UnboxedType(Box(x, p)) <: System.Object } UnboxedType(Box(x, p)) <: System.Object && Box(x, p) == p ==> x == p);

function BoxTester(p: ref, typ: TName) returns (ref);

axiom (forall p: ref, typ: TName :: { BoxTester(p, typ) } UnboxedType(p) == typ <==> BoxTester(p, typ) != null);

axiom (forall p: ref, typ: TName :: { BoxTester(p, typ) } BoxTester(p, typ) != null ==> (forall<T>  :: Box(Unbox(p):T, p) == p));

function BoxDisguise<U>(U) returns (ref);

function UnBoxDisguise<U>(ref) returns (U);

axiom (forall<U> x: ref, p: ref :: { Unbox(Box(x, p)):U } Box(x, p) == p ==> Unbox(Box(x, p)):U == UnBoxDisguise(x) && BoxDisguise(Unbox(Box(x, p)):U) == x);

axiom (forall typ: TName, occurrence: NondetType, activity: ActivityType :: { NewInstance(AllocFunc(typ), occurrence, activity) } $typeof(NewInstance(AllocFunc(typ), occurrence, activity)) == typ && NewInstance(AllocFunc(typ), occurrence, activity) != null);

axiom (forall typ: TName, occurrence: NondetType, activity: ActivityType, heap: HeapType :: { heap[NewInstance(AllocFunc(typ), occurrence, activity), $allocated] } IsHeap(heap) ==> heap[NewInstance(AllocFunc(typ), occurrence, activity), $allocated]);

const unique System.SByte: TName;

axiom $IsValueType(System.SByte);

const unique System.Byte: TName;

axiom $IsValueType(System.Byte);

const unique System.Int16: TName;

axiom $IsValueType(System.Int16);

const unique System.UInt16: TName;

axiom $IsValueType(System.UInt16);

const unique System.Int32: TName;

axiom $IsValueType(System.Int32);

const unique System.UInt32: TName;

axiom $IsValueType(System.UInt32);

const unique System.Int64: TName;

axiom $IsValueType(System.Int64);

const unique System.UInt64: TName;

axiom $IsValueType(System.UInt64);

const unique System.Char: TName;

axiom $IsValueType(System.Char);

const unique System.UIntPtr: TName;

axiom $IsValueType(System.UIntPtr);

const unique System.IntPtr: TName;

axiom $IsValueType(System.IntPtr);

function InRange(i: int, T: TName) returns (bool);

axiom (forall i: int :: InRange(i, System.SByte) <==> 0 - 128 <= i && i < 128);

axiom (forall i: int :: InRange(i, System.Byte) <==> 0 <= i && i < 256);

axiom (forall i: int :: InRange(i, System.Int16) <==> 0 - 32768 <= i && i < 32768);

axiom (forall i: int :: InRange(i, System.UInt16) <==> 0 <= i && i < 65536);

axiom (forall i: int :: InRange(i, System.Int32) <==> 0 - 2147483648 <= i && i <= 2147483647);

axiom (forall i: int :: InRange(i, System.UInt32) <==> 0 <= i && i <= 4294967295);

axiom (forall i: int :: InRange(i, System.Int64) <==> 0 - 9223372036854775808 <= i && i <= 9223372036854775807);

axiom (forall i: int :: InRange(i, System.UInt64) <==> 0 <= i && i <= 18446744073709551615);

axiom (forall i: int :: InRange(i, System.Char) <==> 0 <= i && i < 65536);

function $IntToInt(val: int, fromType: TName, toType: TName) returns (int);

function $IntToReal(int, fromType: TName, toType: TName) returns (real);

function $RealToInt(real, fromType: TName, toType: TName) returns (int);

function $RealToReal(val: real, fromType: TName, toType: TName) returns (real);

axiom (forall z: int, B: TName, C: TName :: InRange(z, C) ==> $IntToInt(z, B, C) == z);

function $SizeIs(TName, int) returns (bool);

function $IfThenElse<a>(bool, a, a) returns (a);

axiom (forall<a> b: bool, x: a, y: a :: { $IfThenElse(b, x, y) } b ==> $IfThenElse(b, x, y) == x);

axiom (forall<a> b: bool, x: a, y: a :: { $IfThenElse(b, x, y) } !b ==> $IfThenElse(b, x, y) == y);

function #neg(int) returns (int);

function #and(int, int) returns (int);

function #or(int, int) returns (int);

function #xor(int, int) returns (int);

function #shl(int, int) returns (int);

function #shr(int, int) returns (int);

function #rneg(real) returns (real);

function #radd(real, real) returns (real);

function #rsub(real, real) returns (real);

function #rmul(real, real) returns (real);

function #rdiv(real, real) returns (real);

function #rmod(real, real) returns (real);

function #rLess(real, real) returns (bool);

function #rAtmost(real, real) returns (bool);

function #rEq(real, real) returns (bool);

function #rNeq(real, real) returns (bool);

function #rAtleast(real, real) returns (bool);

function #rGreater(real, real) returns (bool);

axiom (forall x: int, y: int :: { x % y } { x / y } x % y == x - x / y * y);

axiom (forall x: int, y: int :: { x % y } 0 <= x && 0 < y ==> 0 <= x % y && x % y < y);

axiom (forall x: int, y: int :: { x % y } 0 <= x && y < 0 ==> 0 <= x % y && x % y < 0 - y);

axiom (forall x: int, y: int :: { x % y } x <= 0 && 0 < y ==> 0 - y < x % y && x % y <= 0);

axiom (forall x: int, y: int :: { x % y } x <= 0 && y < 0 ==> y < x % y && x % y <= 0);

axiom (forall x: int, y: int :: { (x + y) % y } 0 <= x && 0 <= y ==> (x + y) % y == x % y);

axiom (forall x: int, y: int :: { (y + x) % y } 0 <= x && 0 <= y ==> (y + x) % y == x % y);

axiom (forall x: int, y: int :: { (x - y) % y } 0 <= x - y && 0 <= y ==> (x - y) % y == x % y);

axiom (forall a: int, b: int, d: int :: { a % d, b % d } 2 <= d && a % d == b % d && a < b ==> a + d <= b);

axiom (forall x: int, y: int :: { #and(x, y) } 0 <= x || 0 <= y ==> 0 <= #and(x, y));

axiom (forall x: int, y: int :: { #or(x, y) } 0 <= x && 0 <= y ==> 0 <= #or(x, y) && #or(x, y) <= x + y);

axiom (forall i: int :: { #shl(i, 0) } #shl(i, 0) == i);

axiom (forall i: int, j: int :: { #shl(i, j) } 1 <= j ==> #shl(i, j) == #shl(i, j - 1) * 2);

axiom (forall i: int, j: int :: { #shl(i, j) } 0 <= i && i < 32768 && 0 <= j && j <= 16 ==> 0 <= #shl(i, j) && #shl(i, j) <= 2147483647);

axiom (forall i: int :: { #shr(i, 0) } #shr(i, 0) == i);

axiom (forall i: int, j: int :: { #shr(i, j) } 1 <= j ==> #shr(i, j) == #shr(i, j - 1) / 2);

function #min(int, int) returns (int);

function #max(int, int) returns (int);

axiom (forall x: int, y: int :: { #min(x, y) } (#min(x, y) == x || #min(x, y) == y) && #min(x, y) <= x && #min(x, y) <= y);

axiom (forall x: int, y: int :: { #max(x, y) } (#max(x, y) == x || #max(x, y) == y) && x <= #max(x, y) && y <= #max(x, y));

function #System.String.IsInterned$System.String$notnull(HeapType, ref) returns (ref);

function #System.String.Equals$System.String(HeapType, ref, ref) returns (bool);

function #System.String.Equals$System.String$System.String(HeapType, ref, ref) returns (bool);

function ##StringEquals(ref, ref) returns (bool);

axiom (forall h: HeapType, a: ref, b: ref :: { #System.String.Equals$System.String(h, a, b) } #System.String.Equals$System.String(h, a, b) == #System.String.Equals$System.String$System.String(h, a, b));

axiom (forall h: HeapType, a: ref, b: ref :: { #System.String.Equals$System.String$System.String(h, a, b) } #System.String.Equals$System.String$System.String(h, a, b) == ##StringEquals(a, b) && #System.String.Equals$System.String$System.String(h, a, b) == ##StringEquals(b, a) && (a == b ==> ##StringEquals(a, b)));

axiom (forall a: ref, b: ref, c: ref :: ##StringEquals(a, b) && ##StringEquals(b, c) ==> ##StringEquals(a, c));

axiom (forall h: HeapType, a: ref, b: ref :: { #System.String.Equals$System.String$System.String(h, a, b) } a != null && b != null && #System.String.Equals$System.String$System.String(h, a, b) ==> #System.String.IsInterned$System.String$notnull(h, a) == #System.String.IsInterned$System.String$notnull(h, b));

const unique Collections.ArrayList._size: Field int;

const unique Collections.ArrayList._items: Field ref;

const unique System.Collections.Comparer.Default: Field ref;

const unique System.Runtime.InteropServices._Exception: TName;

const unique System.ICloneable: TName;

const unique Collections.TestArrayList: TName;

const unique Microsoft.Contracts.GuardException: TName;

const unique System.Collections.IList: TName;

const unique System.Reflection.ICustomAttributeProvider: TName;

const unique System.Collections.Generic.IEnumerable`1...System.Char: TName;

const unique System.IComparable`1...System.String: TName;

const unique System.Collections.IComparer: TName;

const unique System.IEquatable`1...System.String: TName;

const unique System.Collections.ICollection: TName;

const unique System.IConvertible: TName;

const unique System.Collections.IEnumerable: TName;

const unique System.Collections.Comparer: TName;

const unique Microsoft.Contracts.ObjectInvariantException: TName;

const unique Collections.ArrayList: TName;

const unique System.Reflection.MemberInfo: TName;

const unique System.Runtime.Serialization.ISerializable: TName;

const unique System.Exception: TName;

const unique System.Reflection.IReflect: TName;

const unique System.Runtime.InteropServices._Type: TName;

const unique Microsoft.Contracts.ICheckedException: TName;

const unique System.Runtime.InteropServices._MemberInfo: TName;

const unique System.IComparable: TName;

axiom !IsStaticField(Collections.ArrayList._items);

axiom IncludeInMainFrameCondition(Collections.ArrayList._items);

axiom $IncludedInModifiesStar(Collections.ArrayList._items);

axiom AsRepField(Collections.ArrayList._items, Collections.ArrayList) == Collections.ArrayList._items;

axiom DeclType(Collections.ArrayList._items) == Collections.ArrayList;

axiom AsNonNullRefField(Collections.ArrayList._items, RefArray(System.Object, 1)) == Collections.ArrayList._items;

axiom !IsStaticField(Collections.ArrayList._size);

axiom IncludeInMainFrameCondition(Collections.ArrayList._size);

axiom $IncludedInModifiesStar(Collections.ArrayList._size);

axiom DeclType(Collections.ArrayList._size) == Collections.ArrayList;

axiom AsRangeField(Collections.ArrayList._size, System.Int32) == Collections.ArrayList._size;

function #System.Collections.ICollection.get_Count(HeapType, ref) returns (int);

function ##System.Collections.ICollection.get_Count(exposeVersionType) returns (int);

function #Collections.ArrayList.get_Capacity(HeapType, ref) returns (int);

function ##Collections.ArrayList.get_Capacity(exposeVersionType) returns (int);

function #Collections.ArrayList.get_Count(HeapType, ref) returns (int);

function ##Collections.ArrayList.get_Count(exposeVersionType) returns (int);

function #Collections.ArrayList.get_Item$System.Int32(HeapType, ref, int) returns (ref);

function ##Collections.ArrayList.get_Item$System.Int32(exposeVersionType, int) returns (ref);

axiom IsStaticField(System.Collections.Comparer.Default);

axiom !IncludeInMainFrameCondition(System.Collections.Comparer.Default);

axiom $IncludedInModifiesStar(System.Collections.Comparer.Default);

axiom DeclType(System.Collections.Comparer.Default) == System.Collections.Comparer;

axiom AsNonNullRefField(System.Collections.Comparer.Default, System.Collections.Comparer) == System.Collections.Comparer.Default;

axiom Collections.ArrayList <: Collections.ArrayList;

axiom $BaseClass(Collections.ArrayList) == System.Object && AsDirectSubClass(Collections.ArrayList, $BaseClass(Collections.ArrayList)) == Collections.ArrayList;

axiom !$IsImmutable(Collections.ArrayList) && $AsMutable(Collections.ArrayList) == Collections.ArrayList;

axiom System.Array <: System.Array;

axiom $BaseClass(System.Array) == System.Object && AsDirectSubClass(System.Array, $BaseClass(System.Array)) == System.Array;

axiom !$IsImmutable(System.Array) && $AsMutable(System.Array) == System.Array;

axiom System.ICloneable <: System.ICloneable;

axiom $IsMemberlessType(System.ICloneable);

axiom $AsInterface(System.ICloneable) == System.ICloneable;

axiom System.Array <: System.ICloneable;

axiom System.Collections.IList <: System.Collections.IList;

axiom System.Collections.ICollection <: System.Collections.ICollection;

axiom System.Collections.IEnumerable <: System.Collections.IEnumerable;

axiom $IsMemberlessType(System.Collections.IEnumerable);

axiom $AsInterface(System.Collections.IEnumerable) == System.Collections.IEnumerable;

axiom System.Collections.ICollection <: System.Collections.IEnumerable;

axiom $IsMemberlessType(System.Collections.ICollection);

axiom $AsInterface(System.Collections.ICollection) == System.Collections.ICollection;

axiom System.Collections.IList <: System.Collections.ICollection;

axiom System.Collections.IList <: System.Collections.IEnumerable;

axiom $IsMemberlessType(System.Collections.IList);

axiom $AsInterface(System.Collections.IList) == System.Collections.IList;

axiom System.Array <: System.Collections.IList;

axiom System.Array <: System.Collections.ICollection;

axiom System.Array <: System.Collections.IEnumerable;

axiom $IsMemberlessType(System.Array);

// System.Array object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: System.Array } IsHeap($h) && $h[$oi, $inv] <: System.Array && $h[$oi, $localinv] != $BaseClass(System.Array) ==> true);

axiom System.Type <: System.Type;

axiom System.Reflection.MemberInfo <: System.Reflection.MemberInfo;

axiom $BaseClass(System.Reflection.MemberInfo) == System.Object && AsDirectSubClass(System.Reflection.MemberInfo, $BaseClass(System.Reflection.MemberInfo)) == System.Reflection.MemberInfo;

axiom $IsImmutable(System.Reflection.MemberInfo) && $AsImmutable(System.Reflection.MemberInfo) == System.Reflection.MemberInfo;

axiom System.Reflection.ICustomAttributeProvider <: System.Reflection.ICustomAttributeProvider;

axiom $IsMemberlessType(System.Reflection.ICustomAttributeProvider);

axiom $AsInterface(System.Reflection.ICustomAttributeProvider) == System.Reflection.ICustomAttributeProvider;

axiom System.Reflection.MemberInfo <: System.Reflection.ICustomAttributeProvider;

axiom System.Runtime.InteropServices._MemberInfo <: System.Runtime.InteropServices._MemberInfo;

axiom $IsMemberlessType(System.Runtime.InteropServices._MemberInfo);

axiom $AsInterface(System.Runtime.InteropServices._MemberInfo) == System.Runtime.InteropServices._MemberInfo;

axiom System.Reflection.MemberInfo <: System.Runtime.InteropServices._MemberInfo;

axiom $IsMemberlessType(System.Reflection.MemberInfo);

// System.Reflection.MemberInfo object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: System.Reflection.MemberInfo } IsHeap($h) && $h[$oi, $inv] <: System.Reflection.MemberInfo && $h[$oi, $localinv] != $BaseClass(System.Reflection.MemberInfo) ==> true);

axiom $BaseClass(System.Type) == System.Reflection.MemberInfo && AsDirectSubClass(System.Type, $BaseClass(System.Type)) == System.Type;

axiom $IsImmutable(System.Type) && $AsImmutable(System.Type) == System.Type;

axiom System.Runtime.InteropServices._Type <: System.Runtime.InteropServices._Type;

axiom $IsMemberlessType(System.Runtime.InteropServices._Type);

axiom $AsInterface(System.Runtime.InteropServices._Type) == System.Runtime.InteropServices._Type;

axiom System.Type <: System.Runtime.InteropServices._Type;

axiom System.Reflection.IReflect <: System.Reflection.IReflect;

axiom $IsMemberlessType(System.Reflection.IReflect);

axiom $AsInterface(System.Reflection.IReflect) == System.Reflection.IReflect;

axiom System.Type <: System.Reflection.IReflect;

axiom $IsMemberlessType(System.Type);

// System.Type object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: System.Type } IsHeap($h) && $h[$oi, $inv] <: System.Type && $h[$oi, $localinv] != $BaseClass(System.Type) ==> true);

// Collections.ArrayList object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: Collections.ArrayList } IsHeap($h) && $h[$oi, $inv] <: Collections.ArrayList && $h[$oi, $localinv] != $BaseClass(Collections.ArrayList) ==> TypeObject($typeof($h[$oi, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1)) && 0 <= $h[$oi, Collections.ArrayList._size] && $h[$oi, Collections.ArrayList._size] <= $Length($h[$oi, Collections.ArrayList._items]) && (forall ^i: int :: $h[$oi, Collections.ArrayList._size] <= ^i && ^i <= $Length($h[$oi, Collections.ArrayList._items]) - 1 ==> ArrayGet($h[$h[$oi, Collections.ArrayList._items], $elementsRef], ^i) == null));

procedure Collections.ArrayList.SpecSharp.CheckInvariant$System.Boolean(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], throwException$in: bool where true) returns ($result: bool where true);
  // user-declared preconditions
  requires ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this) && (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == this && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.SpecSharp.CheckInvariant$System.Boolean(this: ref, throwException$in: bool) returns ($result: bool)
{
  var throwException: bool where true;
  var stack0o: ref;
  var stack1s: struct;
  var stack1o: ref;
  var stack0b: bool;
  var stack0i: int;
  var stack1i: int;
  var stack50000o: ref;
  var local1: bool where true;
  var local4: bool where true;
  var local2: bool where true;
  var local3: int where InRange(local3, System.Int32);
  var i: int where InRange(i, System.Int32);
  var $Heap$block4046$LoopPreheader: HeapType;

  entry:
    throwException := throwException$in;
    goto block3485;

  block3485:
    goto block3536;

  block3536:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- System.Object.GetType
    stack0o := TypeObject($typeof(stack0o));
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, RefArray(System.Object, 1));
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(RefArray(System.Object, 1));
    // ----- binary operator
    // ----- branch
    goto true3536to3825, false3536to3978;

  true3536to3825:
    assume stack0o == stack1o;
    goto block3825;

  false3536to3978:
    assume stack0o != stack1o;
    goto block3978;

  block3825:
    // ----- load constant 0
    stack0i := 0;
    // ----- load field
    assert this != null;
    stack1i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    // ----- branch
    goto true3825to3604, false3825to3655;

  block3978:
    // ----- copy
    stack0b := throwException;
    // ----- unary operator
    // ----- branch
    goto true3978to3893, false3978to3791;

  true3825to3604:
    assume stack0i > stack1i;
    goto block3604;

  false3825to3655:
    assume stack0i <= stack1i;
    goto block3655;

  block3604:
    // ----- copy
    stack0b := throwException;
    // ----- unary operator
    // ----- branch
    goto true3604to3587, false3604to3995;

  block3655:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- load field
    assert this != null;
    stack1o := $Heap[this, Collections.ArrayList._items];
    // ----- unary operator
    assert stack1o != null;
    stack1i := $Length(stack1o);
    // ----- unary operator
    stack1i := $IntToInt(stack1i, System.UIntPtr, System.Int32);
    // ----- binary operator
    // ----- branch
    goto true3655to3604, false3655to3621;

  true3978to3893:
    assume !stack0b;
    goto block3893;

  false3978to3791:
    assume stack0b;
    goto block3791;

  block3893:
    // ----- load constant 0
    local1 := false;
    // ----- branch
    goto block3842;

  block3791:
    assume false;
    // ----- new object
    havoc stack50000o;
    assume $Heap[stack50000o, $allocated] == false && stack50000o != null && $typeof(stack50000o) == Microsoft.Contracts.ObjectInvariantException;
    assume $Heap[stack50000o, $ownerRef] == stack50000o && $Heap[stack50000o, $ownerFrame] == $PeerGroupPlaceholder;
    // ----- call
    assert stack50000o != null;
    call Microsoft.Contracts.ObjectInvariantException..ctor(stack50000o);
    // ----- copy
    stack0o := stack50000o;
    // ----- throw
    assert stack0o != null;
    assume false;
    return;

  true3604to3587:
    assume !stack0b;
    goto block3587;

  false3604to3995:
    assume stack0b;
    goto block3995;

  block3587:
    // ----- load constant 0
    local1 := false;
    // ----- branch
    goto block3842;

  block3995:
    assume false;
    // ----- new object
    havoc stack50000o;
    assume $Heap[stack50000o, $allocated] == false && stack50000o != null && $typeof(stack50000o) == Microsoft.Contracts.ObjectInvariantException;
    assume $Heap[stack50000o, $ownerRef] == stack50000o && $Heap[stack50000o, $ownerFrame] == $PeerGroupPlaceholder;
    // ----- call
    assert stack50000o != null;
    call Microsoft.Contracts.ObjectInvariantException..ctor(stack50000o);
    // ----- copy
    stack0o := stack50000o;
    // ----- throw
    assert stack0o != null;
    assume false;
    return;

  true3655to3604:
    assume stack0i > stack1i;
    goto block3604;

  false3655to3621:
    assume stack0i <= stack1i;
    goto block3621;

  block3621:
    // ----- branch
    goto block3927;

  block3842:
    // ----- copy
    local4 := local1;
    // ----- copy
    stack0b := local1;
    // ----- return
    $result := stack0b;
    return;

  block3927:
    // ----- load constant 1
    local2 := true;
    // ----- load field
    assert this != null;
    local3 := $Heap[this, Collections.ArrayList._size];
    goto block4046$LoopPreheader;

  block4046:
    // ----- serialized LoopInvariant
    assert $Heap[this, Collections.ArrayList._size] <= i;
    // ----- default loop invariant: allocation and ownership are stable
    assume (forall $o: ref :: { $Heap[$o, $allocated] } $Heap$block4046$LoopPreheader[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } $Heap$block4046$LoopPreheader[$ot, $allocated] && $Heap$block4046$LoopPreheader[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == $Heap$block4046$LoopPreheader[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == $Heap$block4046$LoopPreheader[$ot, $ownerFrame]) && $Heap$block4046$LoopPreheader[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
    // ----- default loop invariant: exposure
    assume (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $Heap$block4046$LoopPreheader[$o, $allocated] ==> $Heap$block4046$LoopPreheader[$o, $inv] == $Heap[$o, $inv] && $Heap$block4046$LoopPreheader[$o, $localinv] == $Heap[$o, $localinv]);
    assume (forall $o: ref :: !$Heap$block4046$LoopPreheader[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
    // ----- default loop invariant: modifies
    assert (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> $Heap$block4046$LoopPreheader[$o, $f] == $Heap[$o, $f]);
    assume $HeapSucc($Heap$block4046$LoopPreheader, $Heap);
    // ----- default loop invariant: owner fields
    assert (forall $o: ref :: { $Heap[$o, $ownerFrame] } { $Heap[$o, $ownerRef] } $o != null && $Heap$block4046$LoopPreheader[$o, $allocated] ==> $Heap[$o, $ownerRef] == $Heap$block4046$LoopPreheader[$o, $ownerRef] && $Heap[$o, $ownerFrame] == $Heap$block4046$LoopPreheader[$o, $ownerFrame]);
    // ----- advance activity
    havoc $ActivityIndicator;
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- unary operator
    assert stack0o != null;
    stack0i := $Length(stack0o);
    // ----- unary operator
    stack0i := $IntToInt(stack0i, System.UIntPtr, System.Int32);
    // ----- load constant 1
    stack1i := 1;
    // ----- binary operator
    stack0i := stack0i - stack1i;
    // ----- binary operator
    // ----- branch
    goto true4046to4012, false4046to3910;

  true4046to4012:
    assume local3 <= stack0i;
    goto block4012;

  false4046to3910:
    assume local3 > stack0i;
    goto block3910;

  block4012:
    // ----- load constant 1
    stack0b := true;
    goto block3961;

  block3910:
    // ----- load constant 0
    stack0b := false;
    // ----- branch
    goto block3961;

  block3961:
    // ----- unary operator
    // ----- branch
    goto true3961to3638, false3961to3723;

  true3961to3638:
    assume !stack0b;
    goto block3638;

  false3961to3723:
    assume stack0b;
    goto block3723;

  block3638:
    // ----- copy
    // ----- branch
    goto true3638to3876, false3638to3740;

  block3723:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := local3;
    // ----- load element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    stack0o := ArrayGet($Heap[stack0o, $elementsRef], stack1i);
    stack1o := null;
    // ----- binary operator
    // ----- branch
    goto true3723to3570, false3723to3689;

  true3723to3570:
    assume stack0o == stack1o;
    goto block3570;

  false3723to3689:
    assume stack0o != stack1o;
    goto block3689;

  block3570:
    // ----- load constant 1
    stack0b := true;
    goto block3519;

  block3689:
    // ----- load constant 0
    stack0b := false;
    // ----- branch
    goto block3519;

  true3638to3876:
    assume local2;
    goto block3876;

  false3638to3740:
    assume !local2;
    goto block3740;

  block3876:
    // ----- load constant 1
    local1 := true;
    // ----- branch
    goto block3842;

  block3740:
    // ----- copy
    stack0b := throwException;
    // ----- unary operator
    // ----- branch
    goto true3740to3672, false3740to3859;

  true3740to3672:
    assume !stack0b;
    goto block3672;

  false3740to3859:
    assume stack0b;
    goto block3859;

  block3672:
    // ----- load constant 0
    local1 := false;
    // ----- branch
    goto block3842;

  block3859:
    assume false;
    // ----- new object
    havoc stack50000o;
    assume $Heap[stack50000o, $allocated] == false && stack50000o != null && $typeof(stack50000o) == Microsoft.Contracts.ObjectInvariantException;
    assume $Heap[stack50000o, $ownerRef] == stack50000o && $Heap[stack50000o, $ownerFrame] == $PeerGroupPlaceholder;
    // ----- call
    assert stack50000o != null;
    call Microsoft.Contracts.ObjectInvariantException..ctor(stack50000o);
    // ----- copy
    stack0o := stack50000o;
    // ----- throw
    assert stack0o != null;
    assume false;
    return;

  block3519:
    // ----- copy
    local2 := stack0b;
    // ----- copy
    // ----- branch
    goto true3519to3502, false3519to3774;

  true3519to3502:
    assume local2;
    goto block3502;

  false3519to3774:
    assume !local2;
    goto block3774;

  block3502:
    // ----- load constant 1
    stack0i := 1;
    // ----- binary operator
    stack0i := local3 + stack0i;
    // ----- copy
    local3 := stack0i;
    // ----- branch
    goto block4046;

  block3774:
    // ----- branch
    goto block3638;

  block4046$LoopPreheader:
    $Heap$block4046$LoopPreheader := $Heap;
    goto block4046;
}



axiom Microsoft.Contracts.ObjectInvariantException <: Microsoft.Contracts.ObjectInvariantException;

axiom Microsoft.Contracts.GuardException <: Microsoft.Contracts.GuardException;

axiom System.Exception <: System.Exception;

axiom $BaseClass(System.Exception) == System.Object && AsDirectSubClass(System.Exception, $BaseClass(System.Exception)) == System.Exception;

axiom !$IsImmutable(System.Exception) && $AsMutable(System.Exception) == System.Exception;

axiom System.Runtime.Serialization.ISerializable <: System.Runtime.Serialization.ISerializable;

axiom $IsMemberlessType(System.Runtime.Serialization.ISerializable);

axiom $AsInterface(System.Runtime.Serialization.ISerializable) == System.Runtime.Serialization.ISerializable;

axiom System.Exception <: System.Runtime.Serialization.ISerializable;

axiom System.Runtime.InteropServices._Exception <: System.Runtime.InteropServices._Exception;

axiom $IsMemberlessType(System.Runtime.InteropServices._Exception);

axiom $AsInterface(System.Runtime.InteropServices._Exception) == System.Runtime.InteropServices._Exception;

axiom System.Exception <: System.Runtime.InteropServices._Exception;

// System.Exception object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: System.Exception } IsHeap($h) && $h[$oi, $inv] <: System.Exception && $h[$oi, $localinv] != $BaseClass(System.Exception) ==> true);

axiom $BaseClass(Microsoft.Contracts.GuardException) == System.Exception && AsDirectSubClass(Microsoft.Contracts.GuardException, $BaseClass(Microsoft.Contracts.GuardException)) == Microsoft.Contracts.GuardException;

axiom !$IsImmutable(Microsoft.Contracts.GuardException) && $AsMutable(Microsoft.Contracts.GuardException) == Microsoft.Contracts.GuardException;

// Microsoft.Contracts.GuardException object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: Microsoft.Contracts.GuardException } IsHeap($h) && $h[$oi, $inv] <: Microsoft.Contracts.GuardException && $h[$oi, $localinv] != $BaseClass(Microsoft.Contracts.GuardException) ==> true);

axiom $BaseClass(Microsoft.Contracts.ObjectInvariantException) == Microsoft.Contracts.GuardException && AsDirectSubClass(Microsoft.Contracts.ObjectInvariantException, $BaseClass(Microsoft.Contracts.ObjectInvariantException)) == Microsoft.Contracts.ObjectInvariantException;

axiom !$IsImmutable(Microsoft.Contracts.ObjectInvariantException) && $AsMutable(Microsoft.Contracts.ObjectInvariantException) == Microsoft.Contracts.ObjectInvariantException;

// Microsoft.Contracts.ObjectInvariantException object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: Microsoft.Contracts.ObjectInvariantException } IsHeap($h) && $h[$oi, $inv] <: Microsoft.Contracts.ObjectInvariantException && $h[$oi, $localinv] != $BaseClass(Microsoft.Contracts.ObjectInvariantException) ==> true);

procedure Microsoft.Contracts.ObjectInvariantException..ctor(this: ref where $IsNotNull(this, Microsoft.Contracts.ObjectInvariantException) && $Heap[this, $allocated]);
  // object is fully unpacked:  this.inv == Object
  free requires ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this);
  // nothing is owned by [this,*] and 'this' is alone in its own peer group
  free requires (forall $o: ref :: $o != this ==> $Heap[$o, $ownerRef] != this) && $Heap[this, $ownerRef] == this && $Heap[this, $ownerFrame] == $PeerGroupPlaceholder;
  free requires $BeingConstructed == this;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // target object is allocated upon return
  free ensures $Heap[this, $allocated];
  // target object is additively exposable for Microsoft.Contracts.ObjectInvariantException
  ensures ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == Microsoft.Contracts.ObjectInvariantException && $Heap[this, $localinv] == $typeof(this);
  ensures $Heap[this, $ownerRef] == old($Heap)[this, $ownerRef] && $Heap[this, $ownerFrame] == old($Heap)[this, $ownerFrame];
  ensures $Heap[this, $sharingMode] == $SharingMode_Unshared;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && ($o != this || !(Microsoft.Contracts.ObjectInvariantException <: DeclType($f))) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] && $o != this ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } $o == this || old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



axiom System.String <: System.String;

axiom $BaseClass(System.String) == System.Object && AsDirectSubClass(System.String, $BaseClass(System.String)) == System.String;

axiom $IsImmutable(System.String) && $AsImmutable(System.String) == System.String;

axiom System.IComparable <: System.IComparable;

axiom $IsMemberlessType(System.IComparable);

axiom $AsInterface(System.IComparable) == System.IComparable;

axiom System.String <: System.IComparable;

axiom System.String <: System.ICloneable;

axiom System.IConvertible <: System.IConvertible;

axiom $IsMemberlessType(System.IConvertible);

axiom $AsInterface(System.IConvertible) == System.IConvertible;

axiom System.String <: System.IConvertible;

axiom System.IComparable`1...System.String <: System.IComparable`1...System.String;

axiom $IsMemberlessType(System.IComparable`1...System.String);

axiom $AsInterface(System.IComparable`1...System.String) == System.IComparable`1...System.String;

axiom System.String <: System.IComparable`1...System.String;

axiom System.Collections.Generic.IEnumerable`1...System.Char <: System.Collections.Generic.IEnumerable`1...System.Char;

axiom System.Collections.Generic.IEnumerable`1...System.Char <: System.Collections.IEnumerable;

axiom $IsMemberlessType(System.Collections.Generic.IEnumerable`1...System.Char);

axiom $AsInterface(System.Collections.Generic.IEnumerable`1...System.Char) == System.Collections.Generic.IEnumerable`1...System.Char;

axiom System.String <: System.Collections.Generic.IEnumerable`1...System.Char;

axiom System.String <: System.Collections.IEnumerable;

axiom System.IEquatable`1...System.String <: System.IEquatable`1...System.String;

axiom $IsMemberlessType(System.IEquatable`1...System.String);

axiom $AsInterface(System.IEquatable`1...System.String) == System.IEquatable`1...System.String;

axiom System.String <: System.IEquatable`1...System.String;

axiom (forall $U: TName :: { $U <: System.String } $U <: System.String ==> $U == System.String);

// System.String object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: System.String } IsHeap($h) && $h[$oi, $inv] <: System.String && $h[$oi, $localinv] != $BaseClass(System.String) ==> true);

procedure Collections.ArrayList..ctor(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]);
  // object is fully unpacked:  this.inv == Object
  free requires ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this);
  // nothing is owned by [this,*] and 'this' is alone in its own peer group
  free requires (forall $o: ref :: $o != this ==> $Heap[$o, $ownerRef] != this) && $Heap[this, $ownerRef] == this && $Heap[this, $ownerFrame] == $PeerGroupPlaceholder;
  free requires $BeingConstructed == this;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $Heap[this, Collections.ArrayList._size] == 0;
  ensures $Length($Heap[this, Collections.ArrayList._items]) == 16;
  // target object is allocated upon return
  free ensures $Heap[this, $allocated];
  // target object is additively exposable for Collections.ArrayList
  ensures ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == Collections.ArrayList && $Heap[this, $localinv] == $typeof(this);
  ensures $Heap[this, $ownerRef] == old($Heap)[this, $ownerRef] && $Heap[this, $ownerFrame] == old($Heap)[this, $ownerFrame];
  ensures $Heap[this, $sharingMode] == $SharingMode_Unshared;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && ($o != this || !(Collections.ArrayList <: DeclType($f))) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] && $o != this ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } $o == this || old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList..ctor(this: ref)
{
  var stack0i: int;
  var stack0o: ref;
  var temp0: ref;
  var temp1: exposeVersionType;
  var temp2: ref;

  entry:
    assume $Heap[this, Collections.ArrayList._size] == 0;
    goto block6681;

  block6681:
    goto block6783;

  block6783:
    // ----- load constant 16
    stack0i := 16;
    // ----- new array
    assert 0 <= stack0i;
    havoc temp0;
    assume $Heap[temp0, $allocated] == false && $Length(temp0) == stack0i;
    assume $Heap[$ElementProxy(temp0, -1), $allocated] == false && $ElementProxy(temp0, -1) != temp0 && $ElementProxy(temp0, -1) != null;
    assume temp0 != null;
    assume $typeof(temp0) == RefArray(System.Object, 1);
    assume $Heap[temp0, $ownerRef] == temp0 && $Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[$ElementProxy(temp0, -1), $ownerRef] == $ElementProxy(temp0, -1) && $Heap[$ElementProxy(temp0, -1), $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[temp0, $inv] == $typeof(temp0) && $Heap[temp0, $localinv] == $typeof(temp0);
    assume (forall $i: int :: ArrayGet($Heap[temp0, $elementsRef], $i) == null);
    $Heap[temp0, $allocated] := true;
    call System.Object..ctor($ElementProxy(temp0, -1));
    stack0o := temp0;
    assume IsHeap($Heap);
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    assert ($Heap[stack0o, $ownerRef] == this && $Heap[stack0o, $ownerFrame] == Collections.ArrayList) || $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder;
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder && $Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList) ==> (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[stack0o, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[stack0o, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder && $Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList) ==> $Heap[this, $ownerRef] != $Heap[stack0o, $ownerRef] || $Heap[this, $ownerFrame] != $Heap[stack0o, $ownerFrame];
    call $UpdateOwnersForRep(this, Collections.ArrayList, stack0o);
    havoc temp1;
    $Heap[this, $exposeVersion] := temp1;
    $Heap[this, Collections.ArrayList._items] := stack0o;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- call
    assert this != null;
    call System.Object..ctor(this);
    $Heap[this, $NonNullFieldsAreInitialized] := true;
    assume IsHeap($Heap);
    goto block6885;

  block6885:
    // ----- FrameGuard processing
    temp2 := this;
    // ----- classic pack
    assert temp2 != null;
    assert $Heap[temp2, $inv] == System.Object && $Heap[temp2, $localinv] == $typeof(temp2);
    assert TypeObject($typeof($Heap[temp2, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp2, Collections.ArrayList._size];
    assert $Heap[temp2, Collections.ArrayList._size] <= $Length($Heap[temp2, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp2, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp2, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp2, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp2 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp2, $inv] := Collections.ArrayList;
    assume IsHeap($Heap);
    goto block6919;

  block6919:
    // ----- nop
    // ----- return
    return;
}



procedure System.Object..ctor(this: ref where $IsNotNull(this, System.Object) && $Heap[this, $allocated]);
  // object is fully unpacked:  this.inv == Object
  free requires ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this);
  // nothing is owned by [this,*] and 'this' is alone in its own peer group
  free requires (forall $o: ref :: $o != this ==> $Heap[$o, $ownerRef] != this) && $Heap[this, $ownerRef] == this && $Heap[this, $ownerFrame] == $PeerGroupPlaceholder;
  free requires $BeingConstructed == this;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // target object is allocated upon return
  free ensures $Heap[this, $allocated];
  // target object is additively exposable for System.Object
  ensures ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this);
  ensures $Heap[this, $ownerRef] == old($Heap)[this, $ownerRef] && $Heap[this, $ownerFrame] == old($Heap)[this, $ownerFrame];
  ensures $Heap[this, $sharingMode] == $SharingMode_Unshared;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && ($o != this || !(System.Object <: DeclType($f))) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] && $o != this ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } $o == this || old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList..ctor$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], capacity$in: int where InRange(capacity$in, System.Int32));
  // object is fully unpacked:  this.inv == Object
  free requires ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this);
  // user-declared preconditions
  requires 0 <= capacity$in;
  // nothing is owned by [this,*] and 'this' is alone in its own peer group
  free requires (forall $o: ref :: $o != this ==> $Heap[$o, $ownerRef] != this) && $Heap[this, $ownerRef] == this && $Heap[this, $ownerFrame] == $PeerGroupPlaceholder;
  free requires $BeingConstructed == this;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $Heap[this, Collections.ArrayList._size] == 0;
  ensures $Length($Heap[this, Collections.ArrayList._items]) == capacity$in;
  // target object is allocated upon return
  free ensures $Heap[this, $allocated];
  // target object is additively exposable for Collections.ArrayList
  ensures ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == Collections.ArrayList && $Heap[this, $localinv] == $typeof(this);
  ensures $Heap[this, $ownerRef] == old($Heap)[this, $ownerRef] && $Heap[this, $ownerFrame] == old($Heap)[this, $ownerFrame];
  ensures $Heap[this, $sharingMode] == $SharingMode_Unshared;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && ($o != this || !(Collections.ArrayList <: DeclType($f))) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] && $o != this ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } $o == this || old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList..ctor$System.Int32(this: ref, capacity$in: int)
{
  var capacity: int where InRange(capacity, System.Int32);
  var stack0i: int;
  var stack0o: ref;
  var temp0: ref;
  var temp1: exposeVersionType;
  var temp2: ref;

  entry:
    capacity := capacity$in;
    assume $Heap[this, Collections.ArrayList._size] == 0;
    goto block7548;

  block7548:
    goto block7871;

  block7871:
    // ----- nop
    // ----- copy
    stack0i := capacity;
    // ----- new array
    assert 0 <= stack0i;
    havoc temp0;
    assume $Heap[temp0, $allocated] == false && $Length(temp0) == stack0i;
    assume $Heap[$ElementProxy(temp0, -1), $allocated] == false && $ElementProxy(temp0, -1) != temp0 && $ElementProxy(temp0, -1) != null;
    assume temp0 != null;
    assume $typeof(temp0) == RefArray(System.Object, 1);
    assume $Heap[temp0, $ownerRef] == temp0 && $Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[$ElementProxy(temp0, -1), $ownerRef] == $ElementProxy(temp0, -1) && $Heap[$ElementProxy(temp0, -1), $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[temp0, $inv] == $typeof(temp0) && $Heap[temp0, $localinv] == $typeof(temp0);
    assume (forall $i: int :: ArrayGet($Heap[temp0, $elementsRef], $i) == null);
    $Heap[temp0, $allocated] := true;
    call System.Object..ctor($ElementProxy(temp0, -1));
    stack0o := temp0;
    assume IsHeap($Heap);
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    assert ($Heap[stack0o, $ownerRef] == this && $Heap[stack0o, $ownerFrame] == Collections.ArrayList) || $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder;
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder && $Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList) ==> (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[stack0o, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[stack0o, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder && $Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList) ==> $Heap[this, $ownerRef] != $Heap[stack0o, $ownerRef] || $Heap[this, $ownerFrame] != $Heap[stack0o, $ownerFrame];
    call $UpdateOwnersForRep(this, Collections.ArrayList, stack0o);
    havoc temp1;
    $Heap[this, $exposeVersion] := temp1;
    $Heap[this, Collections.ArrayList._items] := stack0o;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- call
    assert this != null;
    call System.Object..ctor(this);
    $Heap[this, $NonNullFieldsAreInitialized] := true;
    assume IsHeap($Heap);
    goto block7701;

  block7701:
    // ----- FrameGuard processing
    temp2 := this;
    // ----- classic pack
    assert temp2 != null;
    assert $Heap[temp2, $inv] == System.Object && $Heap[temp2, $localinv] == $typeof(temp2);
    assert TypeObject($typeof($Heap[temp2, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp2, Collections.ArrayList._size];
    assert $Heap[temp2, Collections.ArrayList._size] <= $Length($Heap[temp2, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp2, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp2, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp2, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp2 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp2, $inv] := Collections.ArrayList;
    assume IsHeap($Heap);
    goto block7803;

  block7803:
    // ----- nop
    // ----- return
    return;
}



// purity axiom (confined)
axiom $PurityAxiomsCanBeAssumed ==> (forall $Heap: HeapType, this: ref :: { #System.Collections.ICollection.get_Count($Heap, this) } IsHeap($Heap) && $IsNotNull(this, System.Collections.ICollection) && $Heap[this, $allocated] && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc)) ==> #System.Collections.ICollection.get_Count($Heap, this) >= 0 && ($Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner])) && $AsPureObject(this) == this);

// expose version axiom for confined methods
axiom (forall $Heap: HeapType, this: ref :: { #System.Collections.ICollection.get_Count($Heap, this) } this != null && $typeof(this) <: System.Collections.ICollection && $Heap[this, $inv] == $typeof(this) && $Heap[this, $localinv] == $typeof(this) && IsHeap($Heap) && $Heap[this, $allocated] ==> #System.Collections.ICollection.get_Count($Heap, this) == ##System.Collections.ICollection.get_Count($Heap[this, $exposeVersion]));

procedure Collections.ArrayList..ctor$System.Collections.ICollection$notnull(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], c$in: ref where $IsNotNull(c$in, System.Collections.ICollection) && $Heap[c$in, $allocated]);
  // object is fully unpacked:  this.inv == Object
  free requires ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this);
  // c is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[c$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[c$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // c is peer consistent (owner must not be valid)
  requires $Heap[c$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[c$in, $ownerRef], $inv] <: $Heap[c$in, $ownerFrame]) || $Heap[$Heap[c$in, $ownerRef], $localinv] == $BaseClass($Heap[c$in, $ownerFrame]);
  // nothing is owned by [this,*] and 'this' is alone in its own peer group
  free requires (forall $o: ref :: $o != this ==> $Heap[$o, $ownerRef] != this) && $Heap[this, $ownerRef] == this && $Heap[this, $ownerFrame] == $PeerGroupPlaceholder;
  free requires $BeingConstructed == this;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $Heap[this, Collections.ArrayList._size] == #System.Collections.ICollection.get_Count($Heap, c$in);
  // target object is allocated upon return
  free ensures $Heap[this, $allocated];
  // target object is additively exposable for Collections.ArrayList
  ensures ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == Collections.ArrayList && $Heap[this, $localinv] == $typeof(this);
  ensures $Heap[this, $ownerRef] == old($Heap)[this, $ownerRef] && $Heap[this, $ownerFrame] == old($Heap)[this, $ownerFrame];
  ensures $Heap[this, $sharingMode] == $SharingMode_Unshared;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && ($o != this || !(Collections.ArrayList <: DeclType($f))) && old($o != c$in || !($typeof(c$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old($o != c$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] && $o != this ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } $o == this || old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList..ctor$System.Collections.ICollection$notnull(this: ref, c$in: ref)
{
  var c: ref where $IsNotNull(c, System.Collections.ICollection) && $Heap[c, $allocated];
  var stack0i: int;
  var stack0o: ref;
  var temp0: ref;
  var temp1: exposeVersionType;
  var stack1o: ref;
  var temp2: ref;

  entry:
    c := c$in;
    assume $Heap[this, Collections.ArrayList._size] == 0;
    goto block8500;

  block8500:
    goto block8602;

  block8602:
    // ----- nop
    // ----- call
    assert c != null;
    call stack0i := System.Collections.ICollection.get_Count$.Virtual.$(c, false);
    // ----- new array
    assert 0 <= stack0i;
    havoc temp0;
    assume $Heap[temp0, $allocated] == false && $Length(temp0) == stack0i;
    assume $Heap[$ElementProxy(temp0, -1), $allocated] == false && $ElementProxy(temp0, -1) != temp0 && $ElementProxy(temp0, -1) != null;
    assume temp0 != null;
    assume $typeof(temp0) == RefArray(System.Object, 1);
    assume $Heap[temp0, $ownerRef] == temp0 && $Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[$ElementProxy(temp0, -1), $ownerRef] == $ElementProxy(temp0, -1) && $Heap[$ElementProxy(temp0, -1), $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[temp0, $inv] == $typeof(temp0) && $Heap[temp0, $localinv] == $typeof(temp0);
    assume (forall $i: int :: ArrayGet($Heap[temp0, $elementsRef], $i) == null);
    $Heap[temp0, $allocated] := true;
    call System.Object..ctor($ElementProxy(temp0, -1));
    stack0o := temp0;
    assume IsHeap($Heap);
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    assert ($Heap[stack0o, $ownerRef] == this && $Heap[stack0o, $ownerFrame] == Collections.ArrayList) || $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder;
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder && $Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList) ==> (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[stack0o, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[stack0o, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder && $Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList) ==> $Heap[this, $ownerRef] != $Heap[stack0o, $ownerRef] || $Heap[this, $ownerFrame] != $Heap[stack0o, $ownerFrame];
    call $UpdateOwnersForRep(this, Collections.ArrayList, stack0o);
    havoc temp1;
    $Heap[this, $exposeVersion] := temp1;
    $Heap[this, Collections.ArrayList._items] := stack0o;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- call
    assert this != null;
    call System.Object..ctor(this);
    $Heap[this, $NonNullFieldsAreInitialized] := true;
    assume IsHeap($Heap);
    goto block8772;

  block8772:
    // ----- load constant 0
    stack0i := 0;
    // ----- copy
    stack1o := c;
    // ----- call
    assert this != null;
    call Collections.ArrayList.InsertRangeWorker$System.Int32$System.Collections.ICollection$notnull(this, stack0i, stack1o);
    // ----- FrameGuard processing
    temp2 := this;
    // ----- classic pack
    assert temp2 != null;
    assert $Heap[temp2, $inv] == System.Object && $Heap[temp2, $localinv] == $typeof(temp2);
    assert TypeObject($typeof($Heap[temp2, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp2, Collections.ArrayList._size];
    assert $Heap[temp2, Collections.ArrayList._size] <= $Length($Heap[temp2, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp2, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp2, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp2, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp2 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp2, $inv] := Collections.ArrayList;
    assume IsHeap($Heap);
    goto block8619;

  block8619:
    // ----- nop
    // ----- return
    return;
}



procedure System.Collections.ICollection.get_Count$.Virtual.$(this: ref where $IsNotNull(this, System.Collections.ICollection) && $Heap[this, $allocated], $isBaseCall: bool) returns ($result: int where InRange($result, System.Int32));
  // target object is peer valid (pure method)
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // parameter of a pure method
  free requires $AsPureObject(this) == this;
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result >= 0;
  // FCO info about pure receiver
  free ensures $Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner]);
  // parameter of a pure method
  free ensures $AsPureObject(this) == this;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  free ensures $Heap == old($Heap);
  free ensures $isBaseCall || $result == #System.Collections.ICollection.get_Count($Heap, this);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.InsertRangeWorker$System.Int32$System.Collections.ICollection$notnull(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), c$in: ref where $IsNotNull(c$in, System.Collections.ICollection) && $Heap[c$in, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in <= $Heap[this, Collections.ArrayList._size];
  requires $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
  requires ($Heap[$Heap[this, Collections.ArrayList._items], $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[$Heap[this, Collections.ArrayList._items], $ownerRef], $inv] <: $Heap[$Heap[this, Collections.ArrayList._items], $ownerFrame]) || $Heap[$Heap[$Heap[this, Collections.ArrayList._items], $ownerRef], $localinv] == $BaseClass($Heap[$Heap[this, Collections.ArrayList._items], $ownerFrame])) && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$Heap[this, Collections.ArrayList._items], $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$Heap[this, Collections.ArrayList._items], $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  requires TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
  requires (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
  // target object is exposed for Collections.ArrayList
  requires !($Heap[this, $inv] <: Collections.ArrayList) || $Heap[this, $localinv] == System.Object;
  // c is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[c$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[c$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // c is peer consistent (owner must not be valid)
  requires $Heap[c$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[c$in, $ownerRef], $inv] <: $Heap[c$in, $ownerFrame]) || $Heap[$Heap[c$in, $ownerRef], $localinv] == $BaseClass($Heap[c$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures 0 <= $Heap[this, Collections.ArrayList._size];
  ensures $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
  ensures $Heap[this, Collections.ArrayList._size] == old($Heap[this, Collections.ArrayList._size] + #System.Collections.ICollection.get_Count($Heap, c$in));
  ensures TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
  ensures (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(($o != $Heap[this, Collections.ArrayList._items] || !($typeof($Heap[this, Collections.ArrayList._items]) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != c$in || !($typeof(c$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f))) && old(($o != $Heap[this, Collections.ArrayList._items] || $f != $exposeVersion) && ($o != c$in || $f != $exposeVersion)) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Boogie.ContractConsistencyCheck.get_Capacity(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // target object is peer valid (pure method)
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // parameter of a pure method
  free requires $AsPureObject(this) == this;
  free requires $BeingConstructed == null;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures 0 <= $result;
  // FCO info about pure receiver
  free ensures $Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner]);
  // parameter of a pure method
  free ensures $AsPureObject(this) == this;



implementation Collections.ArrayList.Boogie.ContractConsistencyCheck.get_Capacity(this: ref) returns ($result: int)
{

  entry:
    goto onGuardUpdateWitness1;

  onGuardUpdateWitness1:
    $result := 0;
    goto onPostReturn, onGuardUpdateWitness2;

  onGuardUpdateWitness2:
    assume 0 > $result;
    $result := 1;
    goto onPostReturn, onGuardUpdateWitness3;

  onGuardUpdateWitness3:
    assume 0 > $result;
    $result := 0;
    goto returnBlock;

  onPostReturn:
    assume 0 <= $result;
    return;

  returnBlock:
    return;
}



// purity axiom (confined)
axiom $PurityAxiomsCanBeAssumed ==> (forall $Heap: HeapType, this: ref :: { #Collections.ArrayList.get_Capacity($Heap, this) } IsHeap($Heap) && $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated] && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc)) ==> 0 <= #Collections.ArrayList.get_Capacity($Heap, this) && ($Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner])) && $AsPureObject(this) == this);

// expose version axiom for confined methods
axiom (forall $Heap: HeapType, this: ref :: { #Collections.ArrayList.get_Capacity($Heap, this) } this != null && $typeof(this) <: Collections.ArrayList && $Heap[this, $inv] == $typeof(this) && $Heap[this, $localinv] == $typeof(this) && IsHeap($Heap) && $Heap[this, $allocated] ==> #Collections.ArrayList.get_Capacity($Heap, this) == ##Collections.ArrayList.get_Capacity($Heap[this, $exposeVersion]));

procedure Collections.ArrayList.get_Capacity(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], $isBaseCall: bool) returns ($result: int where InRange($result, System.Int32));
  // target object is peer valid (pure method)
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // parameter of a pure method
  free requires $AsPureObject(this) == this;
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures 0 <= $result;
  // FCO info about pure receiver
  free ensures $Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner]);
  // parameter of a pure method
  free ensures $AsPureObject(this) == this;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  free ensures $Heap == old($Heap);
  free ensures $isBaseCall || $result == #Collections.ArrayList.get_Capacity($Heap, this);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.get_Capacity(this: ref, $isBaseCall: bool) returns ($result: int)
{
  var stack0o: ref;
  var stack0i: int;
  var local1: int where InRange(local1, System.Int32);
  var local3: int where InRange(local3, System.Int32);

  entry:
    goto block9503;

  block9503:
    goto block9656;

  block9656:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- unary operator
    assert stack0o != null;
    stack0i := $Length(stack0o);
    // ----- unary operator
    stack0i := $IntToInt(stack0i, System.UIntPtr, System.Int32);
    // ----- copy
    local1 := stack0i;
    // ----- branch
    goto block9554;

  block9554:
    // ----- nop
    // ----- copy
    local3 := local1;
    // ----- copy
    stack0i := local1;
    // ----- return
    $result := stack0i;
    return;
}



// purity axiom (confined)
axiom $PurityAxiomsCanBeAssumed ==> (forall $Heap: HeapType, this: ref :: { #Collections.ArrayList.get_Count($Heap, this) } IsHeap($Heap) && $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated] && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc)) ==> 0 <= #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Count($Heap, this) == $Heap[this, Collections.ArrayList._size] && ($Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner])) && $AsPureObject(this) == this);

// expose version axiom for confined methods
axiom (forall $Heap: HeapType, this: ref :: { #Collections.ArrayList.get_Count($Heap, this) } this != null && $typeof(this) <: Collections.ArrayList && $Heap[this, $inv] == $typeof(this) && $Heap[this, $localinv] == $typeof(this) && IsHeap($Heap) && $Heap[this, $allocated] ==> #Collections.ArrayList.get_Count($Heap, this) == ##Collections.ArrayList.get_Count($Heap[this, $exposeVersion]));

procedure Collections.ArrayList.set_Capacity$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: int where InRange(value$in, System.Int32));
  // user-declared preconditions
  requires #Collections.ArrayList.get_Count($Heap, this) <= value$in;
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures value$in <= $Length($Heap[this, Collections.ArrayList._items]);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.set_Capacity$System.Int32(this: ref, value$in: int)
{
  var value: int where InRange(value, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0i: int;
  var stack0o: ref;
  var stack0b: bool;
  var stack0s: struct;

  entry:
    value := value$in;
    goto block10625;

  block10625:
    goto block10829;

  block10829:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block10846;

  block10846:
    // ----- copy
    stack0i := value;
    // ----- call
    assert this != null;
    call Collections.ArrayList.EnsureCapacity$System.Int32(this, stack0i);
    // ----- branch
    goto block11033;

  block11033:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true11033to11135, false11033to11101;

  true11033to11135:
    assume local2 == stack0o;
    goto block11135;

  false11033to11101:
    assume local2 != stack0o;
    goto block11101;

  block11135:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block11050;

  block11101:
    // ----- is instance
    // ----- branch
    goto true11101to11135, false11101to11118;

  true11101to11135:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block11135;

  false11101to11118:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block11118;

  block11118:
    // ----- branch
    goto block11050;

  block11050:
    // ----- nop
    // ----- branch
    goto block10982;

  block10982:
    // ----- nop
    // ----- return
    return;
}



procedure Collections.ArrayList.EnsureCapacity$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], desiredCapacity$in: int where InRange(desiredCapacity$in, System.Int32));
  // user-declared preconditions
  requires $Heap[this, Collections.ArrayList._size] <= desiredCapacity$in;
  requires $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
  requires ($Heap[$Heap[this, Collections.ArrayList._items], $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[$Heap[this, Collections.ArrayList._items], $ownerRef], $inv] <: $Heap[$Heap[this, Collections.ArrayList._items], $ownerFrame]) || $Heap[$Heap[$Heap[this, Collections.ArrayList._items], $ownerRef], $localinv] == $BaseClass($Heap[$Heap[this, Collections.ArrayList._items], $ownerFrame])) && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$Heap[this, Collections.ArrayList._items], $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$Heap[this, Collections.ArrayList._items], $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  requires TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
  requires (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
  // target object is exposed for Collections.ArrayList
  requires !($Heap[this, $inv] <: Collections.ArrayList) || $Heap[this, $localinv] == System.Object;
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures desiredCapacity$in <= $Length($Heap[this, Collections.ArrayList._items]);
  ensures $Heap[this, Collections.ArrayList._size] == old($Heap[this, Collections.ArrayList._size]);
  ensures TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
  ensures (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



axiom Microsoft.Contracts.ICheckedException <: Microsoft.Contracts.ICheckedException;

axiom $IsMemberlessType(Microsoft.Contracts.ICheckedException);

axiom $AsInterface(Microsoft.Contracts.ICheckedException) == Microsoft.Contracts.ICheckedException;

procedure Collections.ArrayList.get_Count(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], $isBaseCall: bool) returns ($result: int where InRange($result, System.Int32));
  // target object is peer valid (pure method)
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // parameter of a pure method
  free requires $AsPureObject(this) == this;
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures 0 <= $result;
  ensures $result == $Heap[this, Collections.ArrayList._size];
  // FCO info about pure receiver
  free ensures $Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner]);
  // parameter of a pure method
  free ensures $AsPureObject(this) == this;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  free ensures $Heap == old($Heap);
  free ensures $isBaseCall || $result == #Collections.ArrayList.get_Count($Heap, this);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.get_Count(this: ref, $isBaseCall: bool) returns ($result: int)
{
  var local1: int where InRange(local1, System.Int32);
  var local3: int where InRange(local3, System.Int32);
  var stack0i: int;

  entry:
    goto block12172;

  block12172:
    goto block12444;

  block12444:
    // ----- nop
    // ----- load field
    assert this != null;
    local1 := $Heap[this, Collections.ArrayList._size];
    // ----- branch
    goto block12376;

  block12376:
    // ----- nop
    // ----- copy
    local3 := local1;
    // ----- copy
    stack0i := local1;
    // ----- return
    $result := stack0i;
    return;
}



procedure Collections.ArrayList.Boogie.ContractConsistencyCheck.get_Item$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32)) returns ($result: ref where $Is($result, System.Object) && $Heap[$result, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in < #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer valid (pure method)
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // parameter of a pure method
  free requires $AsPureObject(this) == this;
  free requires $BeingConstructed == null;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result == ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index$in);
  // FCO info about pure receiver
  free ensures $Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner]);
  // parameter of a pure method
  free ensures $AsPureObject(this) == this;
  // return value is peer valid (pure method)
  ensures $result == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));



implementation Collections.ArrayList.Boogie.ContractConsistencyCheck.get_Item$System.Int32(this: ref, index$in: int) returns ($result: ref)
{

  entry:
    goto onGuardUpdateWitness2;

  onGuardUpdateWitness2:
    assert $Is(ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index$in), System.Object);
    $result := ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index$in);
    goto onPostReturn, onGuardUpdateWitness3;

  onGuardUpdateWitness3:
    assume !($result == ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index$in) && ($result == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc))));
    assert $Is(null, System.Object);
    $result := null;
    goto onPostReturn, onGuardUpdateWitness4;

  onGuardUpdateWitness4:
    assume !($result == ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index$in) && ($result == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc))));
    assert $Is($stringLiteral2, System.Object);
    $result := $stringLiteral2;
    goto returnBlock;

  onPostReturn:
    assume $result == ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index$in) && ($result == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc)));
    return;

  returnBlock:
    return;
}



// purity axiom (confined)
axiom $PurityAxiomsCanBeAssumed ==> (forall $Heap: HeapType, this: ref, index$in: int :: { #Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in) } IsHeap($Heap) && $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated] && 0 <= index$in && index$in < #Collections.ArrayList.get_Count($Heap, this) && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc)) ==> $Is(#Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in), System.Object) && $Heap[#Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in), $allocated] && #Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in) == ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index$in) && ($Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner])) && $AsPureObject(this) == this && (#Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in) == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[#Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in), $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[#Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in), $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc))));

// expose version axiom for confined methods
axiom (forall $Heap: HeapType, this: ref, index$in: int :: { #Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in) } this != null && $typeof(this) <: Collections.ArrayList && $Heap[this, $inv] == $typeof(this) && $Heap[this, $localinv] == $typeof(this) && IsHeap($Heap) && $Heap[this, $allocated] ==> #Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in) == ##Collections.ArrayList.get_Item$System.Int32($Heap[this, $exposeVersion], index$in));

procedure Collections.ArrayList.get_Item$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), $isBaseCall: bool) returns ($result: ref where $Is($result, System.Object) && $Heap[$result, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in < #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer valid (pure method)
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // parameter of a pure method
  free requires $AsPureObject(this) == this;
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result == ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index$in);
  // FCO info about pure receiver
  free ensures $Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner]);
  // parameter of a pure method
  free ensures $AsPureObject(this) == this;
  // return value is peer valid (pure method)
  ensures $result == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  free ensures $isBaseCall || $result == #Collections.ArrayList.get_Item$System.Int32($Heap, this, index$in);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.get_Item$System.Int32(this: ref, index$in: int, $isBaseCall: bool) returns ($result: ref)
{
  var index: int where InRange(index, System.Int32);
  var stack0o: ref;
  var stack1i: int;
  var local3: ref where $Is(local3, System.Object) && $Heap[local3, $allocated];
  var local5: ref where $Is(local5, System.Object) && $Heap[local5, $allocated];

  entry:
    index := index$in;
    goto block13090;

  block13090:
    goto block13243;

  block13243:
    // ----- nop
    // ----- serialized AssumeStatement
    assume ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index) == null || (($Heap[ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index), $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index), $ownerRef], $inv] <: $Heap[ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index), $ownerFrame]) || $Heap[$Heap[ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index), $ownerRef], $localinv] == $BaseClass($Heap[ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index), $ownerFrame])) && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index), $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], index), $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc)));
    goto block13260;

  block13260:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- load element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    local3 := ArrayGet($Heap[stack0o, $elementsRef], stack1i);
    // ----- branch
    goto block13107;

  block13107:
    // ----- nop
    // ----- copy
    local5 := local3;
    // ----- copy
    stack0o := local3;
    // ----- return
    $result := stack0o;
    return;
}



procedure Collections.ArrayList.set_Item$System.Int32$System.Object(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in < #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.set_Item$System.Int32$System.Object(this: ref, index$in: int, value$in: ref)
{
  var index: int where InRange(index, System.Int32);
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack1i: int;
  var stack0b: bool;
  var stack0s: struct;

  entry:
    index := index$in;
    value := value$in;
    goto block14484;

  block14484:
    goto block14705;

  block14705:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block14722;

  block14722:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- store element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    assert value == null || $typeof(value) <: $ElementType($typeof(stack0o));
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[stack0o, $ownerRef], $inv] <: $Heap[stack0o, $ownerFrame]) || $Heap[$Heap[stack0o, $ownerRef], $localinv] == $BaseClass($Heap[stack0o, $ownerFrame]);
    $Heap[stack0o, $elementsRef] := ArraySet($Heap[stack0o, $elementsRef], stack1i, value);
    assume IsHeap($Heap);
    // ----- branch
    goto block14858;

  block14858:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true14858to14892, false14858to14841;

  true14858to14892:
    assume local2 == stack0o;
    goto block14892;

  false14858to14841:
    assume local2 != stack0o;
    goto block14841;

  block14892:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block14807;

  block14841:
    // ----- is instance
    // ----- branch
    goto true14841to14892, false14841to14875;

  true14841to14892:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block14892;

  false14841to14875:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block14875;

  block14875:
    // ----- branch
    goto block14807;

  block14807:
    // ----- nop
    // ----- branch
    goto block14773;

  block14773:
    // ----- return
    return;
}



procedure Collections.ArrayList.Add$System.Object(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures #Collections.ArrayList.get_Count($Heap, this) == old(#Collections.ArrayList.get_Count($Heap, this)) + 1;
  ensures #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in;
  ensures $result == old(#Collections.ArrayList.get_Count($Heap, this));
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Add$System.Object(this: ref, value$in: ref) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local4: ref where $Is(local4, System.Exception) && $Heap[local4, $allocated];
  var stack0i: int;
  var stack1i: int;
  var stack0b: bool;
  var stack0o: ref;
  var local5: int where InRange(local5, System.Int32);
  var temp2: exposeVersionType;
  var local6: int where InRange(local6, System.Int32);
  var stack0s: struct;
  var local9: int where InRange(local9, System.Int32);

  entry:
    value := value$in;
    goto block16099;

  block16099:
    goto block16252;

  block16252:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local4 := null;
    goto block16269;

  block16269:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- load field
    assert this != null;
    stack1o := $Heap[this, Collections.ArrayList._items];
    // ----- unary operator
    assert stack1o != null;
    stack1i := $Length(stack1o);
    // ----- unary operator
    stack1i := $IntToInt(stack1i, System.UIntPtr, System.Int32);
    // ----- binary operator
    // ----- branch
    goto true16269to16303, false16269to16286;

  true16269to16303:
    assume stack0i != stack1i;
    goto block16303;

  false16269to16286:
    assume stack0i == stack1i;
    goto block16286;

  block16303:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load field
    assert this != null;
    stack1i := $Heap[this, Collections.ArrayList._size];
    // ----- store element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    assert value == null || $typeof(value) <: $ElementType($typeof(stack0o));
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[stack0o, $ownerRef], $inv] <: $Heap[stack0o, $ownerFrame]) || $Heap[$Heap[stack0o, $ownerRef], $localinv] == $BaseClass($Heap[stack0o, $ownerFrame]);
    $Heap[stack0o, $elementsRef] := ArraySet($Heap[stack0o, $elementsRef], stack1i, value);
    assume IsHeap($Heap);
    // ----- load field
    assert this != null;
    local5 := $Heap[this, Collections.ArrayList._size];
    // ----- load constant 1
    stack0i := 1;
    // ----- binary operator
    stack0i := local5 + stack0i;
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    havoc temp2;
    $Heap[this, $exposeVersion] := temp2;
    $Heap[this, Collections.ArrayList._size] := stack0i;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- copy
    local6 := local5;
    // ----- branch
    goto block16677;

  block16286:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- load constant 1
    stack1i := 1;
    // ----- binary operator
    stack0i := stack0i + stack1i;
    // ----- call
    assert this != null;
    call Collections.ArrayList.EnsureCapacity$System.Int32(this, stack0i);
    goto block16303;

  block16677:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true16677to16626, false16677to16609;

  true16677to16626:
    assume local4 == stack0o;
    goto block16626;

  false16677to16609:
    assume local4 != stack0o;
    goto block16609;

  block16626:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block16643;

  block16609:
    // ----- is instance
    // ----- branch
    goto true16609to16626, false16609to16694;

  true16609to16626:
    assume $As(local4, Microsoft.Contracts.ICheckedException) != null;
    goto block16626;

  false16609to16694:
    assume $As(local4, Microsoft.Contracts.ICheckedException) == null;
    goto block16694;

  block16694:
    // ----- branch
    goto block16643;

  block16643:
    // ----- nop
    // ----- branch
    goto block16558;

  block16558:
    // ----- nop
    // ----- copy
    local9 := local6;
    // ----- copy
    stack0i := local6;
    // ----- return
    $result := stack0i;
    return;
}



implementation Collections.ArrayList.EnsureCapacity$System.Int32(this: ref, desiredCapacity$in: int)
{
  var desiredCapacity: int where InRange(desiredCapacity, System.Int32);
  var stack0o: ref;
  var stack0i: int;
  var stack0b: bool;
  var local4: int where InRange(local4, System.Int32);
  var stack1i: int;
  var stack1o: ref;
  var local7: ref where $Is(local7, RefArray(System.Object, 1)) && $Heap[local7, $allocated];
  var temp0: ref;
  var temp1: exposeVersionType;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;

  entry:
    desiredCapacity := desiredCapacity$in;
    goto block18989;

  block18989:
    goto block19244;

  block19244:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- unary operator
    assert stack0o != null;
    stack0i := $Length(stack0o);
    // ----- unary operator
    stack0i := $IntToInt(stack0i, System.UIntPtr, System.Int32);
    // ----- binary operator
    // ----- branch
    goto true19244to19091, false19244to20315;

  true19244to19091:
    assume stack0i >= desiredCapacity;
    goto block19091;

  false19244to20315:
    assume stack0i < desiredCapacity;
    goto block20315;

  block19091:
    goto block19380;

  block20315:
    // ----- load constant -2147483648
    local4 := -2147483648;
    // ----- load constant 16
    stack0i := 16;
    // ----- binary operator
    // ----- branch
    goto true20315to19822, false20315to19567;

  block19380:
    // ----- nop
    // ----- return
    return;

  true20315to19822:
    assume local4 >= stack0i;
    goto block19822;

  false20315to19567:
    assume local4 < stack0i;
    goto block19567;

  block19822:
    // ----- copy
    stack0i := local4;
    goto block20196;

  block19567:
    // ----- load constant 16
    stack0i := 16;
    // ----- branch
    goto block20196;

  block20196:
    // ----- copy
    local4 := stack0i;
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- unary operator
    assert stack0o != null;
    stack0i := $Length(stack0o);
    // ----- unary operator
    stack0i := $IntToInt(stack0i, System.UIntPtr, System.Int32);
    // ----- load constant 2
    stack1i := 2;
    // ----- binary operator
    stack0i := stack0i * stack1i;
    // ----- binary operator
    // ----- branch
    goto true20196to19193, false20196to19227;

  true20196to19193:
    assume local4 >= stack0i;
    goto block19193;

  false20196to19227:
    assume local4 < stack0i;
    goto block19227;

  block19193:
    // ----- copy
    stack0i := local4;
    goto block19873;

  block19227:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- unary operator
    assert stack0o != null;
    stack0i := $Length(stack0o);
    // ----- unary operator
    stack0i := $IntToInt(stack0i, System.UIntPtr, System.Int32);
    // ----- load constant 2
    stack1i := 2;
    // ----- binary operator
    stack0i := stack0i * stack1i;
    // ----- branch
    goto block19873;

  block19873:
    // ----- copy
    local4 := stack0i;
    // ----- binary operator
    // ----- branch
    goto true19873to19295, false19873to20281;

  true19873to19295:
    assume local4 >= desiredCapacity;
    goto block19295;

  false19873to20281:
    assume local4 < desiredCapacity;
    goto block20281;

  block19295:
    // ----- copy
    stack0i := local4;
    goto block19023;

  block20281:
    // ----- copy
    stack0i := desiredCapacity;
    // ----- branch
    goto block19023;

  block19023:
    // ----- copy
    local4 := stack0i;
    // ----- copy
    desiredCapacity := local4;
    // ----- serialized AssertStatement
    assert desiredCapacity != $Length($Heap[this, Collections.ArrayList._items]);
    goto block20145;

  block20145:
    // ----- nop
    // ----- serialized AssertStatement
    assert desiredCapacity > 0;
    goto block19958;

  block19958:
    // ----- nop
    // ----- copy
    stack0i := desiredCapacity;
    // ----- new array
    assert 0 <= stack0i;
    havoc temp0;
    assume $Heap[temp0, $allocated] == false && $Length(temp0) == stack0i;
    assume $Heap[$ElementProxy(temp0, -1), $allocated] == false && $ElementProxy(temp0, -1) != temp0 && $ElementProxy(temp0, -1) != null;
    assume temp0 != null;
    assume $typeof(temp0) == RefArray(System.Object, 1);
    assume $Heap[temp0, $ownerRef] == temp0 && $Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[$ElementProxy(temp0, -1), $ownerRef] == $ElementProxy(temp0, -1) && $Heap[$ElementProxy(temp0, -1), $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[temp0, $inv] == $typeof(temp0) && $Heap[temp0, $localinv] == $typeof(temp0);
    assume (forall $i: int :: ArrayGet($Heap[temp0, $elementsRef], $i) == null);
    $Heap[temp0, $allocated] := true;
    call System.Object..ctor($ElementProxy(temp0, -1));
    local7 := temp0;
    assume IsHeap($Heap);
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- load constant 0
    stack1i := 0;
    // ----- binary operator
    // ----- branch
    goto true19958to19040, false19958to19601;

  true19958to19040:
    assume stack0i <= stack1i;
    goto block19040;

  false19958to19601:
    assume stack0i > stack1i;
    goto block19601;

  block19040:
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    assert ($Heap[local7, $ownerRef] == this && $Heap[local7, $ownerFrame] == Collections.ArrayList) || $Heap[local7, $ownerFrame] == $PeerGroupPlaceholder;
    assert $Heap[local7, $ownerFrame] == $PeerGroupPlaceholder && $Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList) ==> (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[local7, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[local7, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
    assert $Heap[local7, $ownerFrame] == $PeerGroupPlaceholder && $Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList) ==> $Heap[this, $ownerRef] != $Heap[local7, $ownerRef] || $Heap[this, $ownerFrame] != $Heap[local7, $ownerFrame];
    call $UpdateOwnersForRep(this, Collections.ArrayList, local7);
    havoc temp1;
    $Heap[this, $exposeVersion] := temp1;
    $Heap[this, Collections.ArrayList._items] := local7;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    goto block19380;

  block19601:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 0
    stack1i := 0;
    // ----- copy
    stack2o := local7;
    // ----- load constant 0
    stack3i := 0;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    goto block19040;
}



procedure System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(sourceArray$in: ref where $IsNotNull(sourceArray$in, System.Array) && $Heap[sourceArray$in, $allocated], sourceIndex$in: int where InRange(sourceIndex$in, System.Int32), destinationArray$in: ref where $IsNotNull(destinationArray$in, System.Array) && $Heap[destinationArray$in, $allocated], destinationIndex$in: int where InRange(destinationIndex$in, System.Int32), length$in: int where InRange(length$in, System.Int32));
  // user-declared preconditions
  requires sourceArray$in != null;
  requires destinationArray$in != null;
  requires $Rank(sourceArray$in) == $Rank(destinationArray$in);
  requires sourceIndex$in >= $LBound(sourceArray$in, 0);
  requires destinationIndex$in >= $LBound(destinationArray$in, 0);
  requires length$in >= 0;
  requires sourceIndex$in + length$in <= $LBound(sourceArray$in, 0) + $Length(sourceArray$in);
  requires destinationIndex$in + length$in <= $LBound(destinationArray$in, 0) + $Length(destinationArray$in);
  // sourceArray is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[sourceArray$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[sourceArray$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // sourceArray is peer consistent (owner must not be valid)
  requires $Heap[sourceArray$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[sourceArray$in, $ownerRef], $inv] <: $Heap[sourceArray$in, $ownerFrame]) || $Heap[$Heap[sourceArray$in, $ownerRef], $localinv] == $BaseClass($Heap[sourceArray$in, $ownerFrame]);
  // destinationArray is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[destinationArray$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[destinationArray$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // destinationArray is peer consistent (owner must not be valid)
  requires $Heap[destinationArray$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[destinationArray$in, $ownerRef], $inv] <: $Heap[destinationArray$in, $ownerFrame]) || $Heap[$Heap[destinationArray$in, $ownerRef], $localinv] == $BaseClass($Heap[destinationArray$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // hard-coded postcondition
  ensures (forall $k: int :: { ArrayGet($Heap[destinationArray$in, $elementsBool], $k) } (destinationIndex$in <= $k && $k < destinationIndex$in + length$in ==> old(ArrayGet($Heap[sourceArray$in, $elementsBool], $k + sourceIndex$in - destinationIndex$in)) == ArrayGet($Heap[destinationArray$in, $elementsBool], $k)) && (!(destinationIndex$in <= $k && $k < destinationIndex$in + length$in) ==> old(ArrayGet($Heap[destinationArray$in, $elementsBool], $k)) == ArrayGet($Heap[destinationArray$in, $elementsBool], $k)));
  ensures (forall $k: int :: { ArrayGet($Heap[destinationArray$in, $elementsInt], $k) } (destinationIndex$in <= $k && $k < destinationIndex$in + length$in ==> old(ArrayGet($Heap[sourceArray$in, $elementsInt], $k + sourceIndex$in - destinationIndex$in)) == ArrayGet($Heap[destinationArray$in, $elementsInt], $k)) && (!(destinationIndex$in <= $k && $k < destinationIndex$in + length$in) ==> old(ArrayGet($Heap[destinationArray$in, $elementsInt], $k)) == ArrayGet($Heap[destinationArray$in, $elementsInt], $k)));
  ensures (forall $k: int :: { ArrayGet($Heap[destinationArray$in, $elementsRef], $k) } (destinationIndex$in <= $k && $k < destinationIndex$in + length$in ==> old(ArrayGet($Heap[sourceArray$in, $elementsRef], $k + sourceIndex$in - destinationIndex$in)) == ArrayGet($Heap[destinationArray$in, $elementsRef], $k)) && (!(destinationIndex$in <= $k && $k < destinationIndex$in + length$in) ==> old(ArrayGet($Heap[destinationArray$in, $elementsRef], $k)) == ArrayGet($Heap[destinationArray$in, $elementsRef], $k)));
  ensures (forall $k: int :: { ArrayGet($Heap[destinationArray$in, $elementsReal], $k) } (destinationIndex$in <= $k && $k < destinationIndex$in + length$in ==> old(ArrayGet($Heap[sourceArray$in, $elementsReal], $k + sourceIndex$in - destinationIndex$in)) == ArrayGet($Heap[destinationArray$in, $elementsReal], $k)) && (!(destinationIndex$in <= $k && $k < destinationIndex$in + length$in) ==> old(ArrayGet($Heap[destinationArray$in, $elementsReal], $k)) == ArrayGet($Heap[destinationArray$in, $elementsReal], $k)));
  ensures (forall $k: int :: { ArrayGet($Heap[destinationArray$in, $elementsStruct], $k) } (destinationIndex$in <= $k && $k < destinationIndex$in + length$in ==> old(ArrayGet($Heap[sourceArray$in, $elementsStruct], $k + sourceIndex$in - destinationIndex$in)) == ArrayGet($Heap[destinationArray$in, $elementsStruct], $k)) && (!(destinationIndex$in <= $k && $k < destinationIndex$in + length$in) ==> old(ArrayGet($Heap[destinationArray$in, $elementsStruct], $k)) == ArrayGet($Heap[destinationArray$in, $elementsStruct], $k)));
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != destinationArray$in || !($typeof(destinationArray$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old($o != destinationArray$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.AddRange$System.Collections.ICollection$notnull(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], c$in: ref where $IsNotNull(c$in, System.Collections.ICollection) && $Heap[c$in, $allocated]);
  // user-declared preconditions
  requires !($Heap[this, $ownerRef] == $Heap[c$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[c$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // c is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[c$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[c$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // c is peer consistent (owner must not be valid)
  requires $Heap[c$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[c$in, $ownerRef], $inv] <: $Heap[c$in, $ownerFrame]) || $Heap[$Heap[c$in, $ownerRef], $localinv] == $BaseClass($Heap[c$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(($o != c$in || !($typeof(c$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f))) && old($o != c$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.AddRange$System.Collections.ICollection$notnull(this: ref, c$in: ref)
{
  var c: ref where $IsNotNull(c, System.Collections.ICollection) && $Heap[c, $allocated];
  var stack0i: int;
  var stack1o: ref;

  entry:
    c := c$in;
    goto block21828;

  block21828:
    goto block21845;

  block21845:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- copy
    stack1o := c;
    // ----- call
    assert this != null;
    call Collections.ArrayList.InsertRange$System.Int32$System.Collections.ICollection$notnull$.Virtual.$(this, stack0i, stack1o);
    // ----- return
    return;
}



procedure Collections.ArrayList.InsertRange$System.Int32$System.Collections.ICollection$notnull$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), c$in: ref where $IsNotNull(c$in, System.Collections.ICollection) && $Heap[c$in, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in <= #Collections.ArrayList.get_Count($Heap, this);
  requires !($Heap[this, $ownerRef] == $Heap[c$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[c$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // c is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[c$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[c$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // c is peer consistent (owner must not be valid)
  requires $Heap[c$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[c$in, $ownerRef], $inv] <: $Heap[c$in, $ownerFrame]) || $Heap[$Heap[c$in, $ownerRef], $localinv] == $BaseClass($Heap[c$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(($o != c$in || !($typeof(c$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f))) && old($o != c$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



axiom System.Collections.IComparer <: System.Collections.IComparer;

axiom $IsMemberlessType(System.Collections.IComparer);

axiom $AsInterface(System.Collections.IComparer) == System.Collections.IComparer;

procedure Collections.ArrayList.BinarySearch$System.Int32$System.Int32$System.Object$System.Collections.IComparer(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), count$in: int where InRange(count$in, System.Int32), value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], comparer$in: ref where $Is(comparer$in, System.Collections.IComparer) && $Heap[comparer$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires 0 <= index$in;
  requires 0 <= count$in;
  requires index$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  requires comparer$in == null || !($Heap[this, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[comparer$in, $ownerFrame]);
  requires value$in == null || !($Heap[this, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[value$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  // comparer is peer consistent
  requires comparer$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[comparer$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // comparer is peer consistent (owner must not be valid)
  requires comparer$in == null || $Heap[comparer$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[comparer$in, $ownerRef], $inv] <: $Heap[comparer$in, $ownerFrame]) || $Heap[$Heap[comparer$in, $ownerRef], $localinv] == $BaseClass($Heap[comparer$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures 0 <= $result ==> #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.BinarySearch$System.Int32$System.Int32$System.Object$System.Collections.IComparer(this: ref, index$in: int, count$in: int, value$in: ref, comparer$in: ref) returns ($result: int)
{
  var index: int where InRange(index, System.Int32);
  var count: int where InRange(count, System.Int32);
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var comparer: ref where $Is(comparer, System.Collections.IComparer) && $Heap[comparer, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack1i: int;
  var stack2i: int;
  var stack3o: ref;
  var stack4o: ref;
  var local3: int where InRange(local3, System.Int32);
  var n: int where InRange(n, System.Int32);
  var local5: int where InRange(local5, System.Int32);
  var stack0b: bool;
  var stack0s: struct;
  var local8: int where InRange(local8, System.Int32);
  var stack0i: int;

  entry:
    index := index$in;
    count := count$in;
    value := value$in;
    comparer := comparer$in;
    goto block23375;

  block23375:
    goto block23851;

  block23851:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block23868;

  block23868:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- copy
    stack2i := count;
    // ----- copy
    stack3o := value;
    // ----- copy
    stack4o := comparer;
    // ----- call
    call local3 := System.Array.BinarySearch$System.Array$notnull$System.Int32$System.Int32$System.Object$System.Collections.IComparer(stack0o, stack1i, stack2i, stack3o, stack4o);
    // ----- serialized AssumeStatement
    assume index <= n && n < index + count ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], n) == value;
    goto block24072;

  block24072:
    // ----- nop
    // ----- copy
    local5 := local3;
    // ----- branch
    goto block24514;

  block24514:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true24514to24446, false24514to24565;

  true24514to24446:
    assume local2 == stack0o;
    goto block24446;

  false24514to24565:
    assume local2 != stack0o;
    goto block24565;

  block24446:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block24412;

  block24565:
    // ----- is instance
    // ----- branch
    goto true24565to24446, false24565to24463;

  true24565to24446:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block24446;

  false24565to24463:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block24463;

  block24463:
    // ----- branch
    goto block24412;

  block24412:
    // ----- nop
    // ----- branch
    goto block24378;

  block24378:
    // ----- nop
    // ----- copy
    local8 := local5;
    // ----- copy
    stack0i := local5;
    // ----- return
    $result := stack0i;
    return;
}



procedure System.Array.BinarySearch$System.Array$notnull$System.Int32$System.Int32$System.Object$System.Collections.IComparer(array$in: ref where $IsNotNull(array$in, System.Array) && $Heap[array$in, $allocated], index$in: int where InRange(index$in, System.Int32), length$in: int where InRange(length$in, System.Int32), value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], comparer$in: ref where $Is(comparer$in, System.Collections.IComparer) && $Heap[comparer$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires array$in != null;
  requires $Rank(array$in) == 1;
  requires index$in >= $LBound(array$in, 0);
  requires length$in >= 0;
  requires length$in <= $Length(array$in) - index$in;
  // array is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  // comparer is peer consistent
  requires comparer$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[comparer$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // comparer is peer consistent (owner must not be valid)
  requires comparer$in == null || $Heap[comparer$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[comparer$in, $ownerRef], $inv] <: $Heap[comparer$in, $ownerFrame]) || $Heap[$Heap[comparer$in, $ownerRef], $localinv] == $BaseClass($Heap[comparer$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result == $LBound(array$in, 0) - 1 || (index$in <= $result && $result < index$in + length$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.BinarySearch$System.Object(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires value$in == null || !($Heap[this, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[value$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures 0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) ==> #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.BinarySearch$System.Object(this: ref, value$in: ref) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var stack0i: int;
  var stack1i: int;
  var stack2o: ref;
  var stack3o: ref;
  var local1: int where InRange(local1, System.Int32);
  var local3: int where InRange(local3, System.Int32);

  entry:
    value := value$in;
    goto block25908;

  block25908:
    goto block26010;

  block26010:
    // ----- nop
    // ----- load constant 0
    stack0i := 0;
    // ----- call
    assert this != null;
    call stack1i := Collections.ArrayList.get_Count$.Virtual.$(this, false);
    // ----- copy
    stack2o := value;
    stack3o := null;
    // ----- call
    assert this != null;
    call local1 := Collections.ArrayList.BinarySearch$System.Int32$System.Int32$System.Object$System.Collections.IComparer$.Virtual.$(this, stack0i, stack1i, stack2o, stack3o);
    // ----- branch
    goto block25993;

  block25993:
    // ----- nop
    // ----- copy
    local3 := local1;
    // ----- copy
    stack0i := local1;
    // ----- return
    $result := stack0i;
    return;
}



procedure Collections.ArrayList.get_Count$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], $isBaseCall: bool) returns ($result: int where InRange($result, System.Int32));
  // target object is peer valid (pure method)
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // parameter of a pure method
  free requires $AsPureObject(this) == this;
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures 0 <= $result;
  ensures $result == $Heap[this, Collections.ArrayList._size];
  // FCO info about pure receiver
  free ensures $Heap[this, $ownerFrame] != $PeerGroupPlaceholder ==> ($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame]) ==> $Heap[this, $FirstConsistentOwner] == $Heap[this, $ownerRef]) && (!($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame] && $Heap[$Heap[this, $ownerRef], $localinv] != $BaseClass($Heap[this, $ownerFrame])) ==> $Heap[this, $FirstConsistentOwner] == $Heap[$Heap[this, $ownerRef], $FirstConsistentOwner]);
  // parameter of a pure method
  free ensures $AsPureObject(this) == this;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  free ensures $Heap == old($Heap);
  free ensures $isBaseCall || $result == #Collections.ArrayList.get_Count($Heap, this);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.BinarySearch$System.Int32$System.Int32$System.Object$System.Collections.IComparer$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), count$in: int where InRange(count$in, System.Int32), value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], comparer$in: ref where $Is(comparer$in, System.Collections.IComparer) && $Heap[comparer$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires 0 <= index$in;
  requires 0 <= count$in;
  requires index$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  requires comparer$in == null || !($Heap[this, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[comparer$in, $ownerFrame]);
  requires value$in == null || !($Heap[this, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[value$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  // comparer is peer consistent
  requires comparer$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[comparer$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // comparer is peer consistent (owner must not be valid)
  requires comparer$in == null || $Heap[comparer$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[comparer$in, $ownerRef], $inv] <: $Heap[comparer$in, $ownerFrame]) || $Heap[$Heap[comparer$in, $ownerRef], $localinv] == $BaseClass($Heap[comparer$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures 0 <= $result ==> #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.BinarySearch$System.Object$System.Collections.IComparer(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], comparer$in: ref where $Is(comparer$in, System.Collections.IComparer) && $Heap[comparer$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires value$in == null || !($Heap[this, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[value$in, $ownerFrame]);
  requires comparer$in == null || !($Heap[this, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[comparer$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  // comparer is peer consistent
  requires comparer$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[comparer$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // comparer is peer consistent (owner must not be valid)
  requires comparer$in == null || $Heap[comparer$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[comparer$in, $ownerRef], $inv] <: $Heap[comparer$in, $ownerFrame]) || $Heap[$Heap[comparer$in, $ownerRef], $localinv] == $BaseClass($Heap[comparer$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures 0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) ==> #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.BinarySearch$System.Object$System.Collections.IComparer(this: ref, value$in: ref, comparer$in: ref) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var comparer: ref where $Is(comparer, System.Collections.IComparer) && $Heap[comparer, $allocated];
  var stack0i: int;
  var stack1i: int;
  var stack2o: ref;
  var stack3o: ref;
  var local1: int where InRange(local1, System.Int32);
  var local3: int where InRange(local3, System.Int32);

  entry:
    value := value$in;
    comparer := comparer$in;
    goto block27302;

  block27302:
    goto block27506;

  block27506:
    // ----- nop
    // ----- load constant 0
    stack0i := 0;
    // ----- call
    assert this != null;
    call stack1i := Collections.ArrayList.get_Count$.Virtual.$(this, false);
    // ----- copy
    stack2o := value;
    // ----- copy
    stack3o := comparer;
    // ----- call
    assert this != null;
    call local1 := Collections.ArrayList.BinarySearch$System.Int32$System.Int32$System.Object$System.Collections.IComparer$.Virtual.$(this, stack0i, stack1i, stack2o, stack3o);
    // ----- branch
    goto block27455;

  block27455:
    // ----- nop
    // ----- copy
    local3 := local1;
    // ----- copy
    stack0i := local1;
    // ----- return
    $result := stack0i;
    return;
}



procedure Collections.ArrayList.Clear(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures #Collections.ArrayList.get_Count($Heap, this) == 0;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Clear(this: ref)
{
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack1i: int;
  var stack2i: int;
  var stack0i: int;
  var temp2: exposeVersionType;
  var stack0b: bool;
  var stack0s: struct;

  entry:
    goto block28934;

  block28934:
    goto block29087;

  block29087:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block29104;

  block29104:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 0
    stack1i := 0;
    // ----- load field
    assert this != null;
    stack2i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    call System.Array.Clear$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2i);
    // ----- serialized AssumeStatement
    assume (forall ^i: int :: 0 <= ^i && ^i <= $Heap[this, Collections.ArrayList._size] - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    goto block29376;

  block29376:
    // ----- nop
    // ----- load constant 0
    stack0i := 0;
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    havoc temp2;
    $Heap[this, $exposeVersion] := temp2;
    $Heap[this, Collections.ArrayList._size] := stack0i;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- branch
    goto block29699;

  block29699:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true29699to29563, false29699to29682;

  true29699to29563:
    assume local2 == stack0o;
    goto block29563;

  false29699to29682:
    assume local2 != stack0o;
    goto block29682;

  block29563:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block29614;

  block29682:
    // ----- is instance
    // ----- branch
    goto true29682to29563, false29682to29631;

  true29682to29563:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block29563;

  false29682to29631:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block29631;

  block29631:
    // ----- branch
    goto block29614;

  block29614:
    // ----- nop
    // ----- branch
    goto block29512;

  block29512:
    // ----- nop
    // ----- return
    return;
}



procedure System.Array.Clear$System.Array$notnull$System.Int32$System.Int32(array$in: ref where $IsNotNull(array$in, System.Array) && $Heap[array$in, $allocated], index$in: int where InRange(index$in, System.Int32), length$in: int where InRange(length$in, System.Int32));
  // user-declared preconditions
  requires array$in != null;
  requires $Rank(array$in) == 1;
  requires index$in >= $LBound(array$in, 0);
  requires length$in >= 0;
  requires $Length(array$in) - (index$in + $LBound(array$in, 0)) >= length$in;
  // array is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Clone(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]) returns ($result: ref where $Is($result, System.Object) && $Heap[$result, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // return value is peer consistent
  ensures $result == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // return value is peer consistent (owner must not be valid)
  ensures $result == null || $Heap[$result, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[$result, $ownerRef], $inv] <: $Heap[$result, $ownerFrame]) || $Heap[$Heap[$result, $ownerRef], $localinv] == $BaseClass($Heap[$result, $ownerFrame]);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Clone(this: ref) returns ($result: ref)
{
  var stack0i: int;
  var stack50000o: ref;
  var stack0o: ref;
  var local1: ref where $Is(local1, Collections.ArrayList) && $Heap[local1, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local3: ref where $Is(local3, System.Exception) && $Heap[local3, $allocated];
  var temp2: exposeVersionType;
  var temp3: ref;
  var temp4: exposeVersionType;
  var local5: ref where $Is(local5, System.Exception) && $Heap[local5, $allocated];
  var stack1i: int;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var stack0b: bool;
  var stack0s: struct;
  var local8: ref where $Is(local8, System.Object) && $Heap[local8, $allocated];
  var local9: ref where $Is(local9, System.Object) && $Heap[local9, $allocated];

  entry:
    goto block31093;

  block31093:
    goto block31246;

  block31246:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- new object
    havoc stack50000o;
    assume $Heap[stack50000o, $allocated] == false && stack50000o != null && $typeof(stack50000o) == Collections.ArrayList;
    assume $Heap[stack50000o, $ownerRef] == stack50000o && $Heap[stack50000o, $ownerFrame] == $PeerGroupPlaceholder;
    // ----- call
    assert stack50000o != null;
    call Collections.ArrayList..ctor$System.Int32(stack50000o, stack0i);
    // ----- copy
    stack0o := stack50000o;
    // ----- copy
    local1 := stack0o;
    // ----- FrameGuard processing
    temp0 := local1;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local3 := null;
    goto block31263;

  block31263:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- store field
    assert local1 != null;
    assert $Heap[local1, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[local1, $ownerRef], $inv] <: $Heap[local1, $ownerFrame]) || $Heap[$Heap[local1, $ownerRef], $localinv] == $BaseClass($Heap[local1, $ownerFrame]);
    havoc temp2;
    $Heap[local1, $exposeVersion] := temp2;
    $Heap[local1, Collections.ArrayList._size] := stack0i;
    assert !($Heap[local1, $inv] <: Collections.ArrayList && $Heap[local1, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[local1, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[local1, $inv] <: Collections.ArrayList && $Heap[local1, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[local1, Collections.ArrayList._size];
    assert !($Heap[local1, $inv] <: Collections.ArrayList && $Heap[local1, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[local1, Collections.ArrayList._size] <= $Length($Heap[local1, Collections.ArrayList._items]);
    assert !($Heap[local1, $inv] <: Collections.ArrayList && $Heap[local1, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[local1, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[local1, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[local1, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- FrameGuard processing
    temp3 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp3 != null;
    assert ($Heap[temp3, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp3, $ownerRef], $inv] <: $Heap[temp3, $ownerFrame]) || $Heap[$Heap[temp3, $ownerRef], $localinv] == $BaseClass($Heap[temp3, $ownerFrame])) && $Heap[temp3, $inv] <: Collections.ArrayList && $Heap[temp3, $localinv] == $typeof(temp3);
    $Heap[temp3, $localinv] := System.Object;
    havoc temp4;
    $Heap[temp3, $exposeVersion] := temp4;
    assume IsHeap($Heap);
    local5 := null;
    goto block31280;

  block31280:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 0
    stack1i := 0;
    // ----- load field
    assert local1 != null;
    stack2o := $Heap[local1, Collections.ArrayList._items];
    // ----- load constant 0
    stack3i := 0;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    // ----- branch
    goto block31450;

  block31450:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true31450to31535, false31450to31484;

  true31450to31535:
    assume local5 == stack0o;
    goto block31535;

  false31450to31484:
    assume local5 != stack0o;
    goto block31484;

  block31535:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp3 != null;
    assert $Heap[temp3, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp3, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp3, Collections.ArrayList._size];
    assert $Heap[temp3, Collections.ArrayList._size] <= $Length($Heap[temp3, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp3, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp3, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp3, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp3 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp3, $localinv] := $typeof(temp3);
    assume IsHeap($Heap);
    goto block31518;

  block31484:
    // ----- is instance
    // ----- branch
    goto true31484to31535, false31484to31603;

  true31484to31535:
    assume $As(local5, Microsoft.Contracts.ICheckedException) != null;
    goto block31535;

  false31484to31603:
    assume $As(local5, Microsoft.Contracts.ICheckedException) == null;
    goto block31603;

  block31603:
    // ----- branch
    goto block31518;

  block31518:
    // ----- nop
    // ----- branch
    goto block31331;

  block31331:
    // ----- branch
    goto block31671;

  block31671:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true31671to31569, false31671to31586;

  true31671to31569:
    assume local3 == stack0o;
    goto block31569;

  false31671to31586:
    assume local3 != stack0o;
    goto block31586;

  block31569:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block31467;

  block31586:
    // ----- is instance
    // ----- branch
    goto true31586to31569, false31586to31654;

  true31586to31569:
    assume $As(local3, Microsoft.Contracts.ICheckedException) != null;
    goto block31569;

  false31586to31654:
    assume $As(local3, Microsoft.Contracts.ICheckedException) == null;
    goto block31654;

  block31654:
    // ----- branch
    goto block31467;

  block31467:
    // ----- nop
    // ----- branch
    goto block31382;

  block31382:
    // ----- copy
    local8 := local1;
    // ----- branch
    goto block31399;

  block31399:
    // ----- copy
    local9 := local8;
    // ----- copy
    stack0o := local8;
    // ----- return
    $result := stack0o;
    return;
}



procedure Collections.ArrayList.Contains$System.Object(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], item$in: ref where $Is(item$in, System.Object) && $Heap[item$in, $allocated]) returns ($result: bool where true);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // item is peer consistent
  requires item$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[item$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[item$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // item is peer consistent (owner must not be valid)
  requires item$in == null || $Heap[item$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[item$in, $ownerRef], $inv] <: $Heap[item$in, $ownerFrame]) || $Heap[$Heap[item$in, $ownerRef], $localinv] == $BaseClass($Heap[item$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Contains$System.Object(this: ref, item$in: ref) returns ($result: bool)
{
  var item: ref where $Is(item, System.Object) && $Heap[item, $allocated];
  var stack0o: ref;
  var stack0b: bool;
  var local1: int where InRange(local1, System.Int32);
  var local4: int where InRange(local4, System.Int32);
  var stack0i: int;
  var local2: bool where true;
  var stack1i: int;
  var stack1o: ref;
  var local6: bool where true;
  var local3: int where InRange(local3, System.Int32);
  var local5: int where InRange(local5, System.Int32);
  var $Heap$block33524$LoopPreheader: HeapType;
  var $Heap$block33337$LoopPreheader: HeapType;

  entry:
    item := item$in;
    goto block33303;

  block33303:
    goto block33405;

  block33405:
    // ----- nop
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true33405to33490, false33405to33626;

  true33405to33490:
    assume item != stack0o;
    goto block33490;

  false33405to33626:
    assume item == stack0o;
    goto block33626;

  block33490:
    // ----- load constant 0
    local4 := 0;
    goto block33524$LoopPreheader;

  block33626:
    // ----- load constant 0
    local1 := 0;
    goto block33337$LoopPreheader;

  block33337:
    // ----- default loop invariant: allocation and ownership are stable
    assume (forall $o: ref :: { $Heap[$o, $allocated] } $Heap$block33337$LoopPreheader[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } $Heap$block33337$LoopPreheader[$ot, $allocated] && $Heap$block33337$LoopPreheader[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == $Heap$block33337$LoopPreheader[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == $Heap$block33337$LoopPreheader[$ot, $ownerFrame]) && $Heap$block33337$LoopPreheader[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
    // ----- default loop invariant: exposure
    assume (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $Heap$block33337$LoopPreheader[$o, $allocated] ==> $Heap$block33337$LoopPreheader[$o, $inv] == $Heap[$o, $inv] && $Heap$block33337$LoopPreheader[$o, $localinv] == $Heap[$o, $localinv]);
    assume (forall $o: ref :: !$Heap$block33337$LoopPreheader[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
    // ----- default loop invariant: modifies
    assert (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> $Heap$block33337$LoopPreheader[$o, $f] == $Heap[$o, $f]);
    assume $HeapSucc($Heap$block33337$LoopPreheader, $Heap);
    // ----- default loop invariant: owner fields
    assert (forall $o: ref :: { $Heap[$o, $ownerFrame] } { $Heap[$o, $ownerRef] } $o != null && $Heap$block33337$LoopPreheader[$o, $allocated] ==> $Heap[$o, $ownerRef] == $Heap$block33337$LoopPreheader[$o, $ownerRef] && $Heap[$o, $ownerFrame] == $Heap$block33337$LoopPreheader[$o, $ownerFrame]);
    // ----- advance activity
    havoc $ActivityIndicator;
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    // ----- branch
    goto true33337to33422, false33337to33371;

  true33337to33422:
    assume local1 >= stack0i;
    goto block33422;

  false33337to33371:
    assume local1 < stack0i;
    goto block33371;

  block33422:
    // ----- load constant 0
    local2 := false;
    // ----- branch
    goto block33473;

  block33371:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := local1;
    // ----- load element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    stack0o := ArrayGet($Heap[stack0o, $elementsRef], stack1i);
    stack1o := null;
    // ----- binary operator
    // ----- branch
    goto true33371to33354, false33371to33592;

  block33524:
    // ----- default loop invariant: allocation and ownership are stable
    assume (forall $o: ref :: { $Heap[$o, $allocated] } $Heap$block33524$LoopPreheader[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } $Heap$block33524$LoopPreheader[$ot, $allocated] && $Heap$block33524$LoopPreheader[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == $Heap$block33524$LoopPreheader[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == $Heap$block33524$LoopPreheader[$ot, $ownerFrame]) && $Heap$block33524$LoopPreheader[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
    // ----- default loop invariant: exposure
    assume (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $Heap$block33524$LoopPreheader[$o, $allocated] ==> $Heap$block33524$LoopPreheader[$o, $inv] == $Heap[$o, $inv] && $Heap$block33524$LoopPreheader[$o, $localinv] == $Heap[$o, $localinv]);
    assume (forall $o: ref :: !$Heap$block33524$LoopPreheader[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
    // ----- default loop invariant: modifies
    assert (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> $Heap$block33524$LoopPreheader[$o, $f] == $Heap[$o, $f]);
    assume $HeapSucc($Heap$block33524$LoopPreheader, $Heap);
    // ----- default loop invariant: owner fields
    assert (forall $o: ref :: { $Heap[$o, $ownerFrame] } { $Heap[$o, $ownerRef] } $o != null && $Heap$block33524$LoopPreheader[$o, $allocated] ==> $Heap[$o, $ownerRef] == $Heap$block33524$LoopPreheader[$o, $ownerRef] && $Heap[$o, $ownerFrame] == $Heap$block33524$LoopPreheader[$o, $ownerFrame]);
    // ----- advance activity
    havoc $ActivityIndicator;
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    // ----- branch
    goto true33524to33456, false33524to33388;

  true33524to33456:
    assume local4 >= stack0i;
    goto block33456;

  false33524to33388:
    assume local4 < stack0i;
    goto block33388;

  block33456:
    // ----- load constant 0
    local2 := false;
    // ----- branch
    goto block33473;

  block33388:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := local4;
    // ----- load element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    stack0o := ArrayGet($Heap[stack0o, $elementsRef], stack1i);
    // ----- binary operator
    // ----- branch
    goto true33388to33609, false33388to33575;

  true33371to33354:
    assume stack0o != stack1o;
    goto block33354;

  false33371to33592:
    assume stack0o == stack1o;
    goto block33592;

  block33354:
    // ----- copy
    local3 := local1;
    // ----- load constant 1
    stack0i := 1;
    // ----- binary operator
    stack0i := local3 + stack0i;
    // ----- copy
    local1 := stack0i;
    // ----- copy
    stack0i := local3;
    // ----- branch
    goto block33337;

  block33592:
    // ----- load constant 1
    local2 := true;
    // ----- branch
    goto block33473;

  true33388to33609:
    assume item != stack0o;
    goto block33609;

  false33388to33575:
    assume item == stack0o;
    goto block33575;

  block33609:
    // ----- copy
    local5 := local4;
    // ----- load constant 1
    stack0i := 1;
    // ----- binary operator
    stack0i := local5 + stack0i;
    // ----- copy
    local4 := stack0i;
    // ----- copy
    stack0i := local5;
    // ----- branch
    goto block33524;

  block33575:
    // ----- load constant 1
    local2 := true;
    // ----- branch
    goto block33473;

  block33473:
    // ----- copy
    local6 := local2;
    // ----- copy
    stack0b := local2;
    // ----- return
    $result := stack0b;
    return;

  block33524$LoopPreheader:
    $Heap$block33524$LoopPreheader := $Heap;
    goto block33524;

  block33337$LoopPreheader:
    $Heap$block33337$LoopPreheader := $Heap;
    goto block33337;
}



procedure Collections.ArrayList.CopyTo$System.Array$notnull(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], array$in: ref where $IsNotNull(array$in, System.Array) && $Heap[array$in, $allocated]);
  // user-declared preconditions
  requires #Collections.ArrayList.get_Count($Heap, this) <= $Length(array$in);
  requires $Rank(array$in) == 1;
  requires !($Heap[this, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[array$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // array is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(($o != array$in || !($typeof(array$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f))) && old($o != array$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.CopyTo$System.Array$notnull(this: ref, array$in: ref)
{
  var array: ref where $IsNotNull(array, System.Array) && $Heap[array, $allocated];
  var stack0o: ref;
  var stack1i: int;

  entry:
    array := array$in;
    goto block34765;

  block34765:
    goto block35037;

  block35037:
    // ----- nop
    // ----- copy
    stack0o := array;
    // ----- load constant 0
    stack1i := 0;
    // ----- call
    assert this != null;
    call Collections.ArrayList.CopyTo$System.Array$notnull$System.Int32$.Virtual.$(this, stack0o, stack1i);
    // ----- return
    return;
}



procedure Collections.ArrayList.CopyTo$System.Array$notnull$System.Int32$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], array$in: ref where $IsNotNull(array$in, System.Array) && $Heap[array$in, $allocated], arrayIndex$in: int where InRange(arrayIndex$in, System.Int32));
  // user-declared preconditions
  requires $Rank(array$in) == 1;
  requires 0 <= arrayIndex$in;
  requires arrayIndex$in + #Collections.ArrayList.get_Count($Heap, this) <= $Length(array$in);
  requires !($Heap[this, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[array$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // array is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(($o != array$in || !($typeof(array$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f))) && old($o != array$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.CopyTo$System.Array$notnull$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], array$in: ref where $IsNotNull(array$in, System.Array) && $Heap[array$in, $allocated], arrayIndex$in: int where InRange(arrayIndex$in, System.Int32));
  // user-declared preconditions
  requires $Rank(array$in) == 1;
  requires 0 <= arrayIndex$in;
  requires arrayIndex$in + #Collections.ArrayList.get_Count($Heap, this) <= $Length(array$in);
  requires !($Heap[this, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[array$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // array is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(($o != array$in || !($typeof(array$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f))) && old($o != array$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.CopyTo$System.Array$notnull$System.Int32(this: ref, array$in: ref, arrayIndex$in: int)
{
  var array: ref where $IsNotNull(array, System.Array) && $Heap[array, $allocated];
  var arrayIndex: int where InRange(arrayIndex, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack1i: int;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var stack0b: bool;
  var stack0s: struct;

  entry:
    array := array$in;
    arrayIndex := arrayIndex$in;
    goto block35853;

  block35853:
    goto block36227;

  block36227:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block36244;

  block36244:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 0
    stack1i := 0;
    // ----- copy
    stack2o := array;
    // ----- copy
    stack3i := arrayIndex;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    // ----- branch
    goto block36431;

  block36431:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true36431to36380, false36431to36397;

  true36431to36380:
    assume local2 == stack0o;
    goto block36380;

  false36431to36397:
    assume local2 != stack0o;
    goto block36397;

  block36380:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block36363;

  block36397:
    // ----- is instance
    // ----- branch
    goto true36397to36380, false36397to36346;

  true36397to36380:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block36380;

  false36397to36346:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block36346;

  block36346:
    // ----- branch
    goto block36363;

  block36363:
    // ----- nop
    // ----- branch
    goto block36295;

  block36295:
    // ----- return
    return;
}



procedure Collections.ArrayList.CopyTo$System.Int32$System.Array$notnull$System.Int32$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), array$in: ref where $IsNotNull(array$in, System.Array) && $Heap[array$in, $allocated], arrayIndex$in: int where InRange(arrayIndex$in, System.Int32), count$in: int where InRange(count$in, System.Int32));
  // user-declared preconditions
  requires $Rank(array$in) == 1;
  requires 0 <= index$in;
  requires index$in < #Collections.ArrayList.get_Count($Heap, this);
  requires 0 <= arrayIndex$in;
  requires arrayIndex$in < $Length(array$in);
  requires 0 <= count$in;
  requires index$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  requires arrayIndex$in + count$in <= $Length(array$in);
  requires !($Heap[this, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[array$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // array is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(($o != array$in || !($typeof(array$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f))) && old($o != array$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.CopyTo$System.Int32$System.Array$notnull$System.Int32$System.Int32(this: ref, index$in: int, array$in: ref, arrayIndex$in: int, count$in: int)
{
  var index: int where InRange(index, System.Int32);
  var array: ref where $IsNotNull(array, System.Array) && $Heap[array, $allocated];
  var arrayIndex: int where InRange(arrayIndex, System.Int32);
  var count: int where InRange(count, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack1i: int;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var stack0b: bool;
  var stack0s: struct;

  entry:
    index := index$in;
    array := array$in;
    arrayIndex := arrayIndex$in;
    count := count$in;
    goto block37876;

  block37876:
    goto block38471;

  block38471:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block38488;

  block38488:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- copy
    stack2o := array;
    // ----- copy
    stack3i := arrayIndex;
    // ----- copy
    stack4i := count;
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    // ----- branch
    goto block38641;

  block38641:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true38641to38590, false38641to38692;

  true38641to38590:
    assume local2 == stack0o;
    goto block38590;

  false38641to38692:
    assume local2 != stack0o;
    goto block38692;

  block38590:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block38573;

  block38692:
    // ----- is instance
    // ----- branch
    goto true38692to38590, false38692to38658;

  true38692to38590:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block38590;

  false38692to38658:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block38658;

  block38658:
    // ----- branch
    goto block38573;

  block38573:
    // ----- nop
    // ----- branch
    goto block38539;

  block38539:
    // ----- return
    return;
}



procedure Collections.ArrayList.IndexOf$System.Object(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures -1 <= $result;
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures ($result == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value$in)) || (0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.IndexOf$System.Object(this: ref, value$in: ref) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack2i: int;
  var stack3i: int;
  var local3: int where InRange(local3, System.Int32);
  var stack0b: bool;
  var stack0s: struct;
  var local8: int where InRange(local8, System.Int32);
  var stack0i: int;

  entry:
    value := value$in;
    goto block40341;

  block40341:
    goto block40494;

  block40494:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block40511;

  block40511:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1o := value;
    // ----- load constant 0
    stack2i := 0;
    // ----- load field
    assert this != null;
    stack3i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    call local3 := System.Array.IndexOf...System.Object$System.Object.array$System.Object$System.Int32$System.Int32(stack0o, stack1o, stack2i, stack3i);
    // ----- branch
    goto block41174;

  block41174:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true41174to41191, false41174to41157;

  true41174to41191:
    assume local2 == stack0o;
    goto block41191;

  false41174to41157:
    assume local2 != stack0o;
    goto block41157;

  block41191:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block41140;

  block41157:
    // ----- is instance
    // ----- branch
    goto true41157to41191, false41157to41072;

  true41157to41191:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block41191;

  false41157to41072:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block41072;

  block41072:
    // ----- branch
    goto block41140;

  block41140:
    // ----- nop
    // ----- branch
    goto block41038;

  block41038:
    // ----- nop
    // ----- copy
    local8 := local3;
    // ----- copy
    stack0i := local3;
    // ----- return
    $result := stack0i;
    return;
}



procedure System.Array.IndexOf...System.Object$System.Object.array$System.Object$System.Int32$System.Int32(array$in: ref where $Is(array$in, RefArray(System.Object, 1)) && $Heap[array$in, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], startIndex$in: int where InRange(startIndex$in, System.Int32), count$in: int where InRange(count$in, System.Int32)) returns ($result: int where InRange($result, System.Int32));
  // array is peer consistent
  requires array$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires array$in == null || $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  // value is a peer of the expected elements of the generic object
  requires true;
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.IndexOf$System.Object$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], startIndex$in: int where InRange(startIndex$in, System.Int32)) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires 0 <= startIndex$in;
  requires startIndex$in <= #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures -1 <= $result;
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures ($result == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value$in)) || (0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.IndexOf$System.Object$System.Int32(this: ref, value$in: ref, startIndex$in: int) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var startIndex: int where InRange(startIndex, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack2i: int;
  var stack3i: int;
  var local3: int where InRange(local3, System.Int32);
  var stack0b: bool;
  var stack0s: struct;
  var local8: int where InRange(local8, System.Int32);
  var stack0i: int;

  entry:
    value := value$in;
    startIndex := startIndex$in;
    goto block42857;

  block42857:
    goto block43078;

  block43078:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block43095;

  block43095:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1o := value;
    // ----- copy
    stack2i := startIndex;
    // ----- load field
    assert this != null;
    stack3i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    stack3i := stack3i - startIndex;
    // ----- call
    call local3 := System.Array.IndexOf...System.Object$System.Object.array$System.Object$System.Int32$System.Int32(stack0o, stack1o, stack2i, stack3i);
    // ----- branch
    goto block43690;

  block43690:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true43690to43724, false43690to43656;

  true43690to43724:
    assume local2 == stack0o;
    goto block43724;

  false43690to43656:
    assume local2 != stack0o;
    goto block43656;

  block43724:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block43792;

  block43656:
    // ----- is instance
    // ----- branch
    goto true43656to43724, false43656to43741;

  true43656to43724:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block43724;

  false43656to43741:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block43741;

  block43741:
    // ----- branch
    goto block43792;

  block43792:
    // ----- nop
    // ----- branch
    goto block43622;

  block43622:
    // ----- nop
    // ----- copy
    local8 := local3;
    // ----- copy
    stack0i := local3;
    // ----- return
    $result := stack0i;
    return;
}



procedure Collections.ArrayList.IndexOf$System.Object$System.Int32$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], startIndex$in: int where InRange(startIndex$in, System.Int32), count$in: int where InRange(count$in, System.Int32)) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires 0 <= startIndex$in;
  requires 0 <= count$in;
  requires startIndex$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures -1 <= $result;
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures ($result == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value$in)) || (0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.IndexOf$System.Object$System.Int32$System.Int32(this: ref, value$in: ref, startIndex$in: int, count$in: int) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var startIndex: int where InRange(startIndex, System.Int32);
  var count: int where InRange(count, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack2i: int;
  var stack3i: int;
  var local3: int where InRange(local3, System.Int32);
  var stack0b: bool;
  var stack0s: struct;
  var local8: int where InRange(local8, System.Int32);
  var stack0i: int;

  entry:
    value := value$in;
    startIndex := startIndex$in;
    count := count$in;
    goto block45543;

  block45543:
    goto block45849;

  block45849:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block45866;

  block45866:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1o := value;
    // ----- copy
    stack2i := startIndex;
    // ----- copy
    stack3i := count;
    // ----- call
    call local3 := System.Array.IndexOf...System.Object$System.Object.array$System.Object$System.Int32$System.Int32(stack0o, stack1o, stack2i, stack3i);
    // ----- branch
    goto block46546;

  block46546:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true46546to46563, false46546to46444;

  true46546to46563:
    assume local2 == stack0o;
    goto block46563;

  false46546to46444:
    assume local2 != stack0o;
    goto block46444;

  block46563:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block46529;

  block46444:
    // ----- is instance
    // ----- branch
    goto true46444to46563, false46444to46512;

  true46444to46563:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block46563;

  false46444to46512:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block46512;

  block46512:
    // ----- branch
    goto block46529;

  block46529:
    // ----- nop
    // ----- branch
    goto block46393;

  block46393:
    // ----- nop
    // ----- copy
    local8 := local3;
    // ----- copy
    stack0i := local3;
    // ----- return
    $result := stack0i;
    return;
}



procedure Collections.ArrayList.Insert$System.Int32$System.Object(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in <= #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Insert$System.Int32$System.Object(this: ref, index$in: int, value$in: ref)
{
  var index: int where InRange(index, System.Int32);
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0i: int;
  var stack1i: int;
  var stack0b: bool;
  var stack0o: ref;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var local3: int where InRange(local3, System.Int32);
  var temp2: exposeVersionType;
  var stack0s: struct;

  entry:
    index := index$in;
    value := value$in;
    goto block47804;

  block47804:
    goto block48025;

  block48025:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block48042;

  block48042:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- load field
    assert this != null;
    stack1o := $Heap[this, Collections.ArrayList._items];
    // ----- unary operator
    assert stack1o != null;
    stack1i := $Length(stack1o);
    // ----- unary operator
    stack1i := $IntToInt(stack1i, System.UIntPtr, System.Int32);
    // ----- binary operator
    // ----- branch
    goto true48042to48076, false48042to48059;

  true48042to48076:
    assume stack0i != stack1i;
    goto block48076;

  false48042to48059:
    assume stack0i == stack1i;
    goto block48059;

  block48076:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    // ----- branch
    goto true48076to48110, false48076to48093;

  block48059:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- load constant 1
    stack1i := 1;
    // ----- binary operator
    stack0i := stack0i + stack1i;
    // ----- call
    assert this != null;
    call Collections.ArrayList.EnsureCapacity$System.Int32(this, stack0i);
    goto block48076;

  true48076to48110:
    assume index >= stack0i;
    goto block48110;

  false48076to48093:
    assume index < stack0i;
    goto block48093;

  block48110:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- store element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    assert value == null || $typeof(value) <: $ElementType($typeof(stack0o));
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[stack0o, $ownerRef], $inv] <: $Heap[stack0o, $ownerFrame]) || $Heap[$Heap[stack0o, $ownerRef], $localinv] == $BaseClass($Heap[stack0o, $ownerFrame]);
    $Heap[stack0o, $elementsRef] := ArraySet($Heap[stack0o, $elementsRef], stack1i, value);
    assume IsHeap($Heap);
    // ----- load field
    assert this != null;
    local3 := $Heap[this, Collections.ArrayList._size];
    // ----- load constant 1
    stack0i := 1;
    // ----- binary operator
    stack0i := local3 + stack0i;
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    havoc temp2;
    $Heap[this, $exposeVersion] := temp2;
    $Heap[this, Collections.ArrayList._size] := stack0i;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- copy
    stack0i := local3;
    // ----- branch
    goto block48314;

  block48093:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- load field
    assert this != null;
    stack2o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 1
    stack3i := 1;
    // ----- binary operator
    stack3i := index + stack3i;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    stack4i := stack4i - index;
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    goto block48110;

  block48314:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true48314to48229, false48314to48280;

  true48314to48229:
    assume local2 == stack0o;
    goto block48229;

  false48314to48280:
    assume local2 != stack0o;
    goto block48280;

  block48229:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block48195;

  block48280:
    // ----- is instance
    // ----- branch
    goto true48280to48229, false48280to48212;

  true48280to48229:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block48229;

  false48280to48212:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block48212;

  block48212:
    // ----- branch
    goto block48195;

  block48195:
    // ----- nop
    // ----- branch
    goto block48161;

  block48161:
    // ----- return
    return;
}



procedure Collections.ArrayList.InsertRange$System.Int32$System.Collections.ICollection$notnull(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), c$in: ref where $IsNotNull(c$in, System.Collections.ICollection) && $Heap[c$in, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in <= #Collections.ArrayList.get_Count($Heap, this);
  requires !($Heap[this, $ownerRef] == $Heap[c$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[c$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // c is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[c$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[c$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // c is peer consistent (owner must not be valid)
  requires $Heap[c$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[c$in, $ownerRef], $inv] <: $Heap[c$in, $ownerFrame]) || $Heap[$Heap[c$in, $ownerRef], $localinv] == $BaseClass($Heap[c$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(($o != c$in || !($typeof(c$in) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && ($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f))) && old($o != c$in || $f != $exposeVersion) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.InsertRange$System.Int32$System.Collections.ICollection$notnull(this: ref, index$in: int, c$in: ref)
{
  var index: int where InRange(index, System.Int32);
  var c: ref where $IsNotNull(c, System.Collections.ICollection) && $Heap[c, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0i: int;
  var stack0o: ref;
  var stack0b: bool;
  var stack0s: struct;

  entry:
    index := index$in;
    c := c$in;
    goto block49861;

  block49861:
    goto block50184;

  block50184:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block50201;

  block50201:
    // ----- copy
    stack0i := index;
    // ----- copy
    stack1o := c;
    // ----- call
    assert this != null;
    call Collections.ArrayList.InsertRangeWorker$System.Int32$System.Collections.ICollection$notnull(this, stack0i, stack1o);
    // ----- branch
    goto block50320;

  block50320:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true50320to50337, false50320to50371;

  true50320to50337:
    assume local2 == stack0o;
    goto block50337;

  false50320to50371:
    assume local2 != stack0o;
    goto block50371;

  block50337:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block50405;

  block50371:
    // ----- is instance
    // ----- branch
    goto true50371to50337, false50371to50286;

  true50371to50337:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block50337;

  false50371to50286:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block50286;

  block50286:
    // ----- branch
    goto block50405;

  block50405:
    // ----- nop
    // ----- branch
    goto block50252;

  block50252:
    // ----- return
    return;
}



implementation Collections.ArrayList.InsertRangeWorker$System.Int32$System.Collections.ICollection$notnull(this: ref, index$in: int, c$in: ref)
{
  var index: int where InRange(index, System.Int32);
  var c: ref where $IsNotNull(c, System.Collections.ICollection) && $Heap[c, $allocated];
  var local4: int where InRange(local4, System.Int32);
  var stack0i: int;
  var stack0b: bool;
  var stack0o: ref;
  var stack1i: int;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var temp0: exposeVersionType;

  entry:
    index := index$in;
    c := c$in;
    goto block52037;

  block52037:
    goto block52615;

  block52615:
    // ----- nop
    // ----- call
    assert c != null;
    call local4 := System.Collections.ICollection.get_Count$.Virtual.$(c, false);
    // ----- load constant 0
    stack0i := 0;
    // ----- binary operator
    // ----- branch
    goto true52615to52989, false52615to52326;

  true52615to52989:
    assume local4 <= stack0i;
    goto block52989;

  false52615to52326:
    assume local4 > stack0i;
    goto block52326;

  block52989:
    goto block52751;

  block52326:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    stack0i := stack0i + local4;
    // ----- call
    assert this != null;
    call Collections.ArrayList.EnsureCapacity$System.Int32(this, stack0i);
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    // ----- branch
    goto true52326to52360, false52326to52292;

  true52326to52360:
    assume index >= stack0i;
    goto block52360;

  false52326to52292:
    assume index < stack0i;
    goto block52292;

  block52360:
    // ----- call
    assert c != null;
    call stack0i := System.Collections.ICollection.get_Count$.Virtual.$(c, false);
    // ----- binary operator
    // ----- branch
    goto true52360to52088, false52360to52853;

  block52292:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- load field
    assert this != null;
    stack2o := $Heap[this, Collections.ArrayList._items];
    // ----- binary operator
    stack3i := index + local4;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    stack4i := stack4i - index;
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    goto block52360;

  block52751:
    // ----- nop
    // ----- return
    return;

  true52360to52088:
    assume index >= stack0i;
    goto block52088;

  false52360to52853:
    assume index < stack0i;
    goto block52853;

  block52088:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    stack0i := stack0i + local4;
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    havoc temp0;
    $Heap[this, $exposeVersion] := temp0;
    $Heap[this, Collections.ArrayList._size] := stack0i;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    goto block52751;

  block52853:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- call
    assert c != null;
    call System.Collections.ICollection.CopyTo$System.Array$notnull$System.Int32$.Virtual.$(c, stack0o, stack1i);
    goto block52088;
}



procedure System.Collections.ICollection.CopyTo$System.Array$notnull$System.Int32$.Virtual.$(this: ref where $IsNotNull(this, System.Collections.ICollection) && $Heap[this, $allocated], array$in: ref where $IsNotNull(array$in, System.Array) && $Heap[array$in, $allocated], index$in: int where InRange(index$in, System.Int32));
  // user-declared preconditions
  requires array$in != null;
  requires $Rank(array$in) == 1;
  requires index$in >= 0;
  requires index$in < #System.Collections.ICollection.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // array is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.LastIndexOf$System.Object(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures -1 <= $result;
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures ($result == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value$in)) || (0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.LastIndexOf$System.Object(this: ref, value$in: ref) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var stack0i: int;
  var stack1i: int;
  var stack0b: bool;
  var stack0o: ref;
  var stack2i: int;
  var local1: int where InRange(local1, System.Int32);
  var local5: int where InRange(local5, System.Int32);

  entry:
    value := value$in;
    goto block54417;

  block54417:
    goto block54927;

  block54927:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- load constant 0
    stack1i := 0;
    // ----- binary operator
    // ----- branch
    goto true54927to54451, false54927to54757;

  true54927to54451:
    assume stack0i != stack1i;
    goto block54451;

  false54927to54757:
    assume stack0i == stack1i;
    goto block54757;

  block54451:
    // ----- copy
    stack0o := value;
    // ----- load field
    assert this != null;
    stack1i := $Heap[this, Collections.ArrayList._size];
    // ----- load constant 1
    stack2i := 1;
    // ----- binary operator
    stack1i := stack1i - stack2i;
    // ----- load field
    assert this != null;
    stack2i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    assert this != null;
    call local1 := Collections.ArrayList.LastIndexOf$System.Object$System.Int32$System.Int32$.Virtual.$(this, stack0o, stack1i, stack2i);
    // ----- branch
    goto block55063;

  block54757:
    // ----- load constant -1
    local1 := -1;
    // ----- branch
    goto block55063;

  block55063:
    // ----- nop
    // ----- copy
    local5 := local1;
    // ----- copy
    stack0i := local1;
    // ----- return
    $result := stack0i;
    return;
}



procedure Collections.ArrayList.LastIndexOf$System.Object$System.Int32$System.Int32$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], startIndex$in: int where InRange(startIndex$in, System.Int32), count$in: int where InRange(count$in, System.Int32)) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires 0 <= count$in;
  requires 0 <= startIndex$in;
  requires startIndex$in < #Collections.ArrayList.get_Count($Heap, this);
  requires 0 <= startIndex$in + 1 - count$in;
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures -1 == $result || (startIndex$in + 1 - count$in <= $result && $result <= startIndex$in);
  ensures ($result == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value$in)) || (0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.LastIndexOf$System.Object$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], startIndex$in: int where InRange(startIndex$in, System.Int32)) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires 0 <= startIndex$in;
  requires startIndex$in < #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures -1 <= $result;
  ensures $result <= startIndex$in;
  ensures ($result == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value$in)) || (0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.LastIndexOf$System.Object$System.Int32(this: ref, value$in: ref, startIndex$in: int) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var startIndex: int where InRange(startIndex, System.Int32);
  var stack0o: ref;
  var stack1i: int;
  var stack2i: int;
  var local1: int where InRange(local1, System.Int32);
  var local5: int where InRange(local5, System.Int32);
  var stack0i: int;

  entry:
    value := value$in;
    startIndex := startIndex$in;
    goto block56202;

  block56202:
    goto block56253;

  block56253:
    // ----- nop
    // ----- copy
    stack0o := value;
    // ----- copy
    stack1i := startIndex;
    // ----- load constant 1
    stack2i := 1;
    // ----- binary operator
    stack2i := startIndex + stack2i;
    // ----- call
    assert this != null;
    call local1 := Collections.ArrayList.LastIndexOf$System.Object$System.Int32$System.Int32$.Virtual.$(this, stack0o, stack1i, stack2i);
    // ----- branch
    goto block56542;

  block56542:
    // ----- nop
    // ----- copy
    local5 := local1;
    // ----- copy
    stack0i := local1;
    // ----- return
    $result := stack0i;
    return;
}



procedure Collections.ArrayList.LastIndexOf$System.Object$System.Int32$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], startIndex$in: int where InRange(startIndex$in, System.Int32), count$in: int where InRange(count$in, System.Int32)) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires 0 <= count$in;
  requires 0 <= startIndex$in;
  requires startIndex$in < #Collections.ArrayList.get_Count($Heap, this);
  requires 0 <= startIndex$in + 1 - count$in;
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures -1 == $result || (startIndex$in + 1 - count$in <= $result && $result <= startIndex$in);
  ensures ($result == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value$in)) || (0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.LastIndexOf$System.Object$System.Int32$System.Int32(this: ref, value$in: ref, startIndex$in: int, count$in: int) returns ($result: int)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var startIndex: int where InRange(startIndex, System.Int32);
  var count: int where InRange(count, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack2i: int;
  var stack3i: int;
  var local3: int where InRange(local3, System.Int32);
  var n: int where InRange(n, System.Int32);
  var local7: int where InRange(local7, System.Int32);
  var stack0b: bool;
  var stack0s: struct;
  var local12: int where InRange(local12, System.Int32);
  var stack0i: int;

  entry:
    value := value$in;
    startIndex := startIndex$in;
    count := count$in;
    goto block58837;

  block58837:
    goto block59160;

  block59160:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block59177;

  block59177:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1o := value;
    // ----- copy
    stack2i := startIndex;
    // ----- copy
    stack3i := count;
    // ----- call
    call local3 := System.Array.LastIndexOf...System.Object$System.Object.array$System.Object$System.Int32$System.Int32(stack0o, stack1o, stack2i, stack3i);
    // ----- serialized AssumeStatement
    assume (n == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value)) || (0 <= n && n < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, n) == value);
    goto block59551;

  block59551:
    // ----- nop
    // ----- copy
    local7 := local3;
    // ----- branch
    goto block60163;

  block60163:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true60163to60197, false60163to60231;

  true60163to60197:
    assume local2 == stack0o;
    goto block60197;

  false60163to60231:
    assume local2 != stack0o;
    goto block60231;

  block60197:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block60214;

  block60231:
    // ----- is instance
    // ----- branch
    goto true60231to60197, false60231to60248;

  true60231to60197:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block60197;

  false60231to60248:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block60248;

  block60248:
    // ----- branch
    goto block60214;

  block60214:
    // ----- nop
    // ----- branch
    goto block60129;

  block60129:
    // ----- nop
    // ----- copy
    local12 := local7;
    // ----- copy
    stack0i := local7;
    // ----- return
    $result := stack0i;
    return;
}



procedure System.Array.LastIndexOf...System.Object$System.Object.array$System.Object$System.Int32$System.Int32(array$in: ref where $Is(array$in, RefArray(System.Object, 1)) && $Heap[array$in, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], startIndex$in: int where InRange(startIndex$in, System.Int32), count$in: int where InRange(count$in, System.Int32)) returns ($result: int where InRange($result, System.Int32));
  // array is peer consistent
  requires array$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires array$in == null || $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  // value is a peer of the expected elements of the generic object
  requires true;
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Remove$System.Object(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], obj$in: ref where $Is(obj$in, System.Object) && $Heap[obj$in, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // obj is peer consistent
  requires obj$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[obj$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[obj$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // obj is peer consistent (owner must not be valid)
  requires obj$in == null || $Heap[obj$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[obj$in, $ownerRef], $inv] <: $Heap[obj$in, $ownerFrame]) || $Heap[$Heap[obj$in, $ownerRef], $localinv] == $BaseClass($Heap[obj$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Remove$System.Object(this: ref, obj$in: ref)
{
  var obj: ref where $Is(obj, System.Object) && $Heap[obj, $allocated];
  var stack0o: ref;
  var local1: int where InRange(local1, System.Int32);
  var stack0i: int;
  var stack0b: bool;

  entry:
    obj := obj$in;
    goto block61336;

  block61336:
    goto block61472;

  block61472:
    // ----- nop
    // ----- copy
    stack0o := obj;
    // ----- call
    assert this != null;
    call local1 := Collections.ArrayList.IndexOf$System.Object$.Virtual.$(this, stack0o);
    // ----- load constant 0
    stack0i := 0;
    // ----- binary operator
    // ----- branch
    goto true61472to61438, false61472to61455;

  true61472to61438:
    assume stack0i > local1;
    goto block61438;

  false61472to61455:
    assume stack0i <= local1;
    goto block61455;

  block61438:
    // ----- return
    return;

  block61455:
    // ----- copy
    stack0i := local1;
    // ----- call
    assert this != null;
    call Collections.ArrayList.RemoveAt$System.Int32$.Virtual.$(this, stack0i);
    goto block61438;
}



procedure Collections.ArrayList.IndexOf$System.Object$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures -1 <= $result;
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures ($result == -1 && !(exists ^i: int :: 0 <= ^i && ^i <= #Collections.ArrayList.get_Count($Heap, this) - 1 && #Collections.ArrayList.get_Item$System.Int32($Heap, this, ^i) == value$in)) || (0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) && #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.RemoveAt$System.Int32$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32));
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in < #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.RemoveAt$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32));
  // user-declared preconditions
  requires 0 <= index$in;
  requires index$in < #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.RemoveAt$System.Int32(this: ref, index$in: int)
{
  var index: int where InRange(index, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var local3: int where InRange(local3, System.Int32);
  var stack0i: int;
  var temp2: exposeVersionType;
  var stack0b: bool;
  var stack0o: ref;
  var stack1i: int;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var stack0s: struct;

  entry:
    index := index$in;
    goto block62203;

  block62203:
    goto block62424;

  block62424:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block62441;

  block62441:
    // ----- load field
    assert this != null;
    local3 := $Heap[this, Collections.ArrayList._size];
    // ----- load constant 1
    stack0i := 1;
    // ----- binary operator
    stack0i := local3 - stack0i;
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    havoc temp2;
    $Heap[this, $exposeVersion] := temp2;
    $Heap[this, Collections.ArrayList._size] := stack0i;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- copy
    stack0i := local3;
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    // ----- branch
    goto true62441to62475, false62441to62458;

  true62441to62475:
    assume index >= stack0i;
    goto block62475;

  false62441to62458:
    assume index < stack0i;
    goto block62458;

  block62475:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load field
    assert this != null;
    stack1i := $Heap[this, Collections.ArrayList._size];
    stack2o := null;
    // ----- store element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    assert stack2o == null || $typeof(stack2o) <: $ElementType($typeof(stack0o));
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[stack0o, $ownerRef], $inv] <: $Heap[stack0o, $ownerFrame]) || $Heap[$Heap[stack0o, $ownerRef], $localinv] == $BaseClass($Heap[stack0o, $ownerFrame]);
    $Heap[stack0o, $elementsRef] := ArraySet($Heap[stack0o, $elementsRef], stack1i, stack2o);
    assume IsHeap($Heap);
    // ----- branch
    goto block62560;

  block62458:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 1
    stack1i := 1;
    // ----- binary operator
    stack1i := index + stack1i;
    // ----- load field
    assert this != null;
    stack2o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack3i := index;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    stack4i := stack4i - index;
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    goto block62475;

  block62560:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true62560to62594, false62560to62611;

  true62560to62594:
    assume local2 == stack0o;
    goto block62594;

  false62560to62611:
    assume local2 != stack0o;
    goto block62611;

  block62594:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block62577;

  block62611:
    // ----- is instance
    // ----- branch
    goto true62611to62594, false62611to62662;

  true62611to62594:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block62594;

  false62611to62662:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block62662;

  block62662:
    // ----- branch
    goto block62577;

  block62577:
    // ----- nop
    // ----- branch
    goto block62526;

  block62526:
    // ----- return
    return;
}



procedure Collections.ArrayList.RemoveRange$System.Int32$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), count$in: int where InRange(count$in, System.Int32));
  // user-declared preconditions
  requires 0 <= index$in;
  requires 0 <= count$in;
  requires index$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.RemoveRange$System.Int32$System.Int32(this: ref, index$in: int, count$in: int)
{
  var index: int where InRange(index, System.Int32);
  var count: int where InRange(count, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0i: int;
  var stack0b: bool;
  var local3: int where InRange(local3, System.Int32);
  var temp2: exposeVersionType;
  var stack0o: ref;
  var stack1i: int;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var local4: ref where $Is(local4, RefArray(System.Object, 1)) && $Heap[local4, $allocated];
  var i: int where InRange(i, System.Int32);
  var itemsBeforeLoop: ref where $Is(itemsBeforeLoop, RefArray(System.Object, 1)) && $Heap[itemsBeforeLoop, $allocated];
  var stack0s: struct;
  var local8: int where InRange(local8, System.Int32);
  var $Heap$block64940$LoopPreheader: HeapType;

  entry:
    index := index$in;
    count := count$in;
    goto block64549;

  block64549:
    goto block64855;

  block64855:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block64872;

  block64872:
    // ----- load constant 0
    stack0i := 0;
    // ----- binary operator
    // ----- branch
    goto true64872to65365, false64872to64889;

  true64872to65365:
    assume count <= stack0i;
    goto block65365;

  false64872to64889:
    assume count > stack0i;
    goto block64889;

  block65365:
    // ----- branch
    goto block65535;

  block64889:
    // ----- load field
    assert this != null;
    local3 := $Heap[this, Collections.ArrayList._size];
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    stack0i := stack0i - count;
    // ----- store field
    assert this != null;
    assert $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
    havoc temp2;
    $Heap[this, $exposeVersion] := temp2;
    $Heap[this, Collections.ArrayList._size] := stack0i;
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || TypeObject($typeof($Heap[this, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || 0 <= $Heap[this, Collections.ArrayList._size];
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || $Heap[this, Collections.ArrayList._size] <= $Length($Heap[this, Collections.ArrayList._items]);
    assert !($Heap[this, $inv] <: Collections.ArrayList && $Heap[this, $localinv] != $BaseClass(Collections.ArrayList)) || (forall ^i: int :: $Heap[this, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assume IsHeap($Heap);
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    // ----- branch
    goto true64889to64923, false64889to64906;

  true64889to64923:
    assume index >= stack0i;
    goto block64923;

  false64889to64906:
    assume index < stack0i;
    goto block64906;

  block64923:
    // ----- load field
    assert this != null;
    local4 := $Heap[this, Collections.ArrayList._items];
    goto block64940$LoopPreheader;

  block64906:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- binary operator
    stack1i := index + count;
    // ----- load field
    assert this != null;
    stack2o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack3i := index;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    stack4i := stack4i - index;
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    goto block64923;

  block65535:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true65535to65586, false65535to65450;

  true65535to65586:
    assume local2 == stack0o;
    goto block65586;

  false65535to65450:
    assume local2 != stack0o;
    goto block65450;

  block65586:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block65484;

  block65450:
    // ----- is instance
    // ----- branch
    goto true65450to65586, false65450to65501;

  block64940:
    // ----- serialized LoopInvariant
    assert 0 <= $Heap[this, Collections.ArrayList._size];
    // ----- serialized LoopInvariant
    assert $Heap[this, Collections.ArrayList._size] <= i;
    // ----- serialized LoopInvariant
    assert i <= $Length($Heap[this, Collections.ArrayList._items]);
    // ----- serialized LoopInvariant
    assert $Heap[this, Collections.ArrayList._items] == itemsBeforeLoop;
    // ----- serialized LoopInvariant
    assert (forall ^j: int :: i <= ^j && ^j <= $Length($Heap[this, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[this, Collections.ArrayList._items], $elementsRef], ^j) == null);
    // ----- default loop invariant: allocation and ownership are stable
    assume (forall $o: ref :: { $Heap[$o, $allocated] } $Heap$block64940$LoopPreheader[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } $Heap$block64940$LoopPreheader[$ot, $allocated] && $Heap$block64940$LoopPreheader[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == $Heap$block64940$LoopPreheader[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == $Heap$block64940$LoopPreheader[$ot, $ownerFrame]) && $Heap$block64940$LoopPreheader[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
    // ----- default loop invariant: exposure
    assume (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $Heap$block64940$LoopPreheader[$o, $allocated] ==> $Heap$block64940$LoopPreheader[$o, $inv] == $Heap[$o, $inv] && $Heap$block64940$LoopPreheader[$o, $localinv] == $Heap[$o, $localinv]);
    assume (forall $o: ref :: !$Heap$block64940$LoopPreheader[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
    // ----- default loop invariant: modifies
    assert (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> $Heap$block64940$LoopPreheader[$o, $f] == $Heap[$o, $f]);
    assume $HeapSucc($Heap$block64940$LoopPreheader, $Heap);
    // ----- default loop invariant: owner fields
    assert (forall $o: ref :: { $Heap[$o, $ownerFrame] } { $Heap[$o, $ownerRef] } $o != null && $Heap$block64940$LoopPreheader[$o, $allocated] ==> $Heap[$o, $ownerRef] == $Heap$block64940$LoopPreheader[$o, $ownerRef] && $Heap[$o, $ownerFrame] == $Heap$block64940$LoopPreheader[$o, $ownerFrame]);
    // ----- advance activity
    havoc $ActivityIndicator;
    goto block65331;

  true65450to65586:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block65586;

  false65450to65501:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block65501;

  block65501:
    // ----- branch
    goto block65484;

  block65331:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- binary operator
    // ----- branch
    goto true65331to65365, false65331to65348;

  true65331to65365:
    assume stack0i >= local3;
    goto block65365;

  false65331to65348:
    assume stack0i < local3;
    goto block65348;

  block65348:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 1
    stack1i := 1;
    // ----- binary operator
    stack1i := local3 - stack1i;
    // ----- copy
    local8 := stack1i;
    // ----- copy
    local3 := local8;
    // ----- copy
    stack1i := local8;
    stack2o := null;
    // ----- store element
    assert stack0o != null;
    assert 0 <= stack1i;
    assert stack1i < $Length(stack0o);
    assert stack2o == null || $typeof(stack2o) <: $ElementType($typeof(stack0o));
    assert $Heap[stack0o, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[stack0o, $ownerRef], $inv] <: $Heap[stack0o, $ownerFrame]) || $Heap[$Heap[stack0o, $ownerRef], $localinv] == $BaseClass($Heap[stack0o, $ownerFrame]);
    $Heap[stack0o, $elementsRef] := ArraySet($Heap[stack0o, $elementsRef], stack1i, stack2o);
    assume IsHeap($Heap);
    // ----- branch
    goto block64940;

  block65484:
    // ----- nop
    // ----- branch
    goto block65416;

  block65416:
    // ----- return
    return;

  block64940$LoopPreheader:
    $Heap$block64940$LoopPreheader := $Heap;
    goto block64940;
}



procedure Collections.ArrayList.Repeat$System.Object$System.Int32(value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated], count$in: int where InRange(count$in, System.Int32)) returns ($result: ref where $IsNotNull($result, Collections.ArrayList) && $Heap[$result, $allocated]);
  // user-declared preconditions
  requires 0 <= count$in;
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // return value is peer consistent
  ensures (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // return value is peer consistent (owner must not be valid)
  ensures $Heap[$result, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[$result, $ownerRef], $inv] <: $Heap[$result, $ownerFrame]) || $Heap[$Heap[$result, $ownerRef], $localinv] == $BaseClass($Heap[$result, $ownerFrame]);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Repeat$System.Object$System.Int32(value$in: ref, count$in: int) returns ($result: ref)
{
  var value: ref where $Is(value, System.Object) && $Heap[value, $allocated];
  var count: int where InRange(count, System.Int32);
  var local2: int where InRange(local2, System.Int32);
  var stack0b: bool;
  var stack0i: int;
  var stack50000o: ref;
  var stack0o: ref;
  var local1: ref where $Is(local1, Collections.ArrayList) && $Heap[local1, $allocated];
  var local3: int where InRange(local3, System.Int32);
  var stack1o: ref;
  var list: ref where $Is(list, Collections.ArrayList) && $Heap[list, $allocated];
  var local6: ref where $Is(local6, Collections.ArrayList) && $Heap[local6, $allocated];
  var local5: int where InRange(local5, System.Int32);
  var local7: ref where $Is(local7, Collections.ArrayList) && $Heap[local7, $allocated];
  var $Heap$block67609$LoopPreheader: HeapType;

  entry:
    value := value$in;
    count := count$in;
    goto block67320;

  block67320:
    goto block67354;

  block67354:
    // ----- nop
    // ----- load constant -2147483648
    local2 := -2147483648;
    // ----- binary operator
    // ----- branch
    goto true67354to67388, false67354to67694;

  true67354to67388:
    assume local2 >= count;
    goto block67388;

  false67354to67694:
    assume local2 < count;
    goto block67694;

  block67388:
    // ----- copy
    stack0i := local2;
    goto block67405;

  block67694:
    // ----- copy
    stack0i := count;
    // ----- branch
    goto block67405;

  block67405:
    // ----- copy
    local2 := stack0i;
    // ----- load constant 16
    stack0i := 16;
    // ----- binary operator
    // ----- branch
    goto true67405to67558, false67405to67507;

  true67405to67558:
    assume local2 >= stack0i;
    goto block67558;

  false67405to67507:
    assume local2 < stack0i;
    goto block67507;

  block67558:
    // ----- copy
    stack0i := local2;
    goto block67643;

  block67507:
    // ----- load constant 16
    stack0i := 16;
    // ----- branch
    goto block67643;

  block67643:
    // ----- copy
    local2 := stack0i;
    // ----- copy
    stack0i := local2;
    // ----- new object
    havoc stack50000o;
    assume $Heap[stack50000o, $allocated] == false && stack50000o != null && $typeof(stack50000o) == Collections.ArrayList;
    assume $Heap[stack50000o, $ownerRef] == stack50000o && $Heap[stack50000o, $ownerFrame] == $PeerGroupPlaceholder;
    // ----- call
    assert stack50000o != null;
    call Collections.ArrayList..ctor$System.Int32(stack50000o, stack0i);
    // ----- copy
    stack0o := stack50000o;
    // ----- copy
    local1 := stack0o;
    // ----- load constant 0
    local3 := 0;
    goto block67609$LoopPreheader;

  block67609:
    // ----- serialized LoopInvariant
    assert ($Heap[list, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[list, $ownerRef], $inv] <: $Heap[list, $ownerFrame]) || $Heap[$Heap[list, $ownerRef], $localinv] == $BaseClass($Heap[list, $ownerFrame])) && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[list, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[list, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
    // ----- default loop invariant: allocation and ownership are stable
    assume (forall $o: ref :: { $Heap[$o, $allocated] } $Heap$block67609$LoopPreheader[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } $Heap$block67609$LoopPreheader[$ot, $allocated] && $Heap$block67609$LoopPreheader[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == $Heap$block67609$LoopPreheader[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == $Heap$block67609$LoopPreheader[$ot, $ownerFrame]) && $Heap$block67609$LoopPreheader[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
    // ----- default loop invariant: exposure
    assume (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $Heap$block67609$LoopPreheader[$o, $allocated] ==> $Heap$block67609$LoopPreheader[$o, $inv] == $Heap[$o, $inv] && $Heap$block67609$LoopPreheader[$o, $localinv] == $Heap[$o, $localinv]);
    assume (forall $o: ref :: !$Heap$block67609$LoopPreheader[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
    // ----- default loop invariant: modifies
    assert (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> $Heap$block67609$LoopPreheader[$o, $f] == $Heap[$o, $f]);
    assume $HeapSucc($Heap$block67609$LoopPreheader, $Heap);
    // ----- default loop invariant: owner fields
    assert (forall $o: ref :: { $Heap[$o, $ownerFrame] } { $Heap[$o, $ownerRef] } $o != null && $Heap$block67609$LoopPreheader[$o, $allocated] ==> $Heap[$o, $ownerRef] == $Heap$block67609$LoopPreheader[$o, $ownerRef] && $Heap[$o, $ownerFrame] == $Heap$block67609$LoopPreheader[$o, $ownerFrame]);
    // ----- advance activity
    havoc $ActivityIndicator;
    goto block67371;

  block67371:
    // ----- nop
    // ----- binary operator
    // ----- branch
    goto true67371to67456, false67371to67490;

  true67371to67456:
    assume local3 >= count;
    goto block67456;

  false67371to67490:
    assume local3 < count;
    goto block67490;

  block67456:
    // ----- copy
    local6 := local1;
    // ----- branch
    goto block67592;

  block67490:
    // ----- copy
    stack0o := value;
    // ----- call
    assert local1 != null;
    call stack0i := Collections.ArrayList.Add$System.Object$.Virtual.$(local1, stack0o);
    // ----- copy
    local5 := local3;
    // ----- load constant 1
    stack0i := 1;
    // ----- binary operator
    stack0i := local5 + stack0i;
    // ----- copy
    local3 := stack0i;
    // ----- copy
    stack0i := local5;
    // ----- branch
    goto block67609;

  block67592:
    // ----- copy
    local7 := local6;
    // ----- copy
    stack0o := local6;
    // ----- return
    $result := stack0o;
    return;

  block67609$LoopPreheader:
    $Heap$block67609$LoopPreheader := $Heap;
    goto block67609;
}



procedure Collections.ArrayList.Add$System.Object$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures #Collections.ArrayList.get_Count($Heap, this) == old(#Collections.ArrayList.get_Count($Heap, this)) + 1;
  ensures #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in;
  ensures $result == old(#Collections.ArrayList.get_Count($Heap, this));
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Reverse(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Reverse(this: ref)
{
  var stack0i: int;
  var stack1i: int;

  entry:
    goto block68612;

  block68612:
    goto block68697;

  block68697:
    // ----- nop
    // ----- load constant 0
    stack0i := 0;
    // ----- call
    assert this != null;
    call stack1i := Collections.ArrayList.get_Count$.Virtual.$(this, false);
    // ----- call
    assert this != null;
    call Collections.ArrayList.Reverse$System.Int32$System.Int32$.Virtual.$(this, stack0i, stack1i);
    // ----- return
    return;
}



procedure Collections.ArrayList.Reverse$System.Int32$System.Int32$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), count$in: int where InRange(count$in, System.Int32));
  // user-declared preconditions
  requires 0 <= index$in;
  requires 0 <= count$in;
  requires index$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Reverse$System.Int32$System.Int32(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), count$in: int where InRange(count$in, System.Int32));
  // user-declared preconditions
  requires 0 <= index$in;
  requires 0 <= count$in;
  requires index$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Reverse$System.Int32$System.Int32(this: ref, index$in: int, count$in: int)
{
  var index: int where InRange(index, System.Int32);
  var count: int where InRange(count, System.Int32);
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack1i: int;
  var stack2i: int;
  var stack0b: bool;
  var stack0s: struct;

  entry:
    index := index$in;
    count := count$in;
    goto block69428;

  block69428:
    goto block69734;

  block69734:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block69751;

  block69751:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- copy
    stack2i := count;
    // ----- call
    call System.Array.Reverse$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2i);
    // ----- branch
    goto block69904;

  block69904:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true69904to69921, false69904to69955;

  true69904to69921:
    assume local2 == stack0o;
    goto block69921;

  false69904to69955:
    assume local2 != stack0o;
    goto block69955;

  block69921:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block69887;

  block69955:
    // ----- is instance
    // ----- branch
    goto true69955to69921, false69955to69938;

  true69955to69921:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block69921;

  false69955to69938:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block69938;

  block69938:
    // ----- branch
    goto block69887;

  block69887:
    // ----- nop
    // ----- branch
    goto block69802;

  block69802:
    // ----- return
    return;
}



procedure System.Array.Reverse$System.Array$notnull$System.Int32$System.Int32(array$in: ref where $IsNotNull(array$in, System.Array) && $Heap[array$in, $allocated], index$in: int where InRange(index$in, System.Int32), length$in: int where InRange(length$in, System.Int32));
  // user-declared preconditions
  requires array$in != null;
  requires $Rank(array$in) == 1;
  requires length$in >= 0;
  requires index$in >= $LBound(array$in, 0);
  requires $LBound(array$in, 0) + index$in + length$in <= $Length(array$in);
  // array is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Sort(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Sort(this: ref)
{
  var stack0o: ref;
  var stack0i: int;
  var stack1i: int;
  var stack2o: ref;

  entry:
    goto block70788;

  block70788:
    goto block70822;

  block70822:
    // ----- nop
    // ----- serialized AssumeStatement
    assume ($Heap[$Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default], $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[$Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default], $ownerRef], $inv] <: $Heap[$Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default], $ownerFrame]) || $Heap[$Heap[$Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default], $ownerRef], $localinv] == $BaseClass($Heap[$Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default], $ownerFrame])) && (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default], $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default], $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
    // ----- serialized AssumeStatement
    assume $Heap[$Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default], $ownerFrame] == $PeerGroupPlaceholder;
    goto block70992;

  block70992:
    // ----- nop
    // ----- load constant 0
    stack0i := 0;
    // ----- call
    assert this != null;
    call stack1i := Collections.ArrayList.get_Count$.Virtual.$(this, false);
    // ----- load field
    stack2o := $Heap[ClassRepr(System.Collections.Comparer), System.Collections.Comparer.Default];
    // ----- call
    assert this != null;
    call Collections.ArrayList.Sort$System.Int32$System.Int32$System.Collections.IComparer$.Virtual.$(this, stack0i, stack1i, stack2o);
    // ----- return
    return;
}



axiom System.Collections.Comparer <: System.Collections.Comparer;

axiom $BaseClass(System.Collections.Comparer) == System.Object && AsDirectSubClass(System.Collections.Comparer, $BaseClass(System.Collections.Comparer)) == System.Collections.Comparer;

axiom !$IsImmutable(System.Collections.Comparer) && $AsMutable(System.Collections.Comparer) == System.Collections.Comparer;

axiom System.Collections.Comparer <: System.Collections.IComparer;

axiom System.Collections.Comparer <: System.Runtime.Serialization.ISerializable;

axiom (forall $U: TName :: { $U <: System.Collections.Comparer } $U <: System.Collections.Comparer ==> $U == System.Collections.Comparer);

// System.Collections.Comparer object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: System.Collections.Comparer } IsHeap($h) && $h[$oi, $inv] <: System.Collections.Comparer && $h[$oi, $localinv] != $BaseClass(System.Collections.Comparer) ==> true);

procedure Collections.ArrayList.Sort$System.Int32$System.Int32$System.Collections.IComparer$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), count$in: int where InRange(count$in, System.Int32), comparer$in: ref where $Is(comparer$in, System.Collections.IComparer) && $Heap[comparer$in, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires 0 <= count$in;
  requires index$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  requires comparer$in == null || !($Heap[this, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[comparer$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // comparer is peer consistent
  requires comparer$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[comparer$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // comparer is peer consistent (owner must not be valid)
  requires comparer$in == null || $Heap[comparer$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[comparer$in, $ownerRef], $inv] <: $Heap[comparer$in, $ownerFrame]) || $Heap[$Heap[comparer$in, $ownerRef], $localinv] == $BaseClass($Heap[comparer$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Sort$System.Collections.IComparer(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], comparer$in: ref where $Is(comparer$in, System.Collections.IComparer) && $Heap[comparer$in, $allocated]);
  // user-declared preconditions
  requires comparer$in == null || !($Heap[this, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[comparer$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // comparer is peer consistent
  requires comparer$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[comparer$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // comparer is peer consistent (owner must not be valid)
  requires comparer$in == null || $Heap[comparer$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[comparer$in, $ownerRef], $inv] <: $Heap[comparer$in, $ownerFrame]) || $Heap[$Heap[comparer$in, $ownerRef], $localinv] == $BaseClass($Heap[comparer$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Sort$System.Collections.IComparer(this: ref, comparer$in: ref)
{
  var comparer: ref where $Is(comparer, System.Collections.IComparer) && $Heap[comparer, $allocated];
  var stack0i: int;
  var stack1i: int;
  var stack2o: ref;

  entry:
    comparer := comparer$in;
    goto block71553;

  block71553:
    goto block71740;

  block71740:
    // ----- nop
    // ----- load constant 0
    stack0i := 0;
    // ----- call
    assert this != null;
    call stack1i := Collections.ArrayList.get_Count$.Virtual.$(this, false);
    // ----- copy
    stack2o := comparer;
    // ----- call
    assert this != null;
    call Collections.ArrayList.Sort$System.Int32$System.Int32$System.Collections.IComparer$.Virtual.$(this, stack0i, stack1i, stack2o);
    // ----- return
    return;
}



procedure Collections.ArrayList.Sort$System.Int32$System.Int32$System.Collections.IComparer(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], index$in: int where InRange(index$in, System.Int32), count$in: int where InRange(count$in, System.Int32), comparer$in: ref where $Is(comparer$in, System.Collections.IComparer) && $Heap[comparer$in, $allocated]);
  // user-declared preconditions
  requires 0 <= index$in;
  requires 0 <= count$in;
  requires index$in + count$in <= #Collections.ArrayList.get_Count($Heap, this);
  requires comparer$in == null || !($Heap[this, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[comparer$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // comparer is peer consistent
  requires comparer$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[comparer$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // comparer is peer consistent (owner must not be valid)
  requires comparer$in == null || $Heap[comparer$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[comparer$in, $ownerRef], $inv] <: $Heap[comparer$in, $ownerFrame]) || $Heap[$Heap[comparer$in, $ownerRef], $localinv] == $BaseClass($Heap[comparer$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.Sort$System.Int32$System.Int32$System.Collections.IComparer(this: ref, index$in: int, count$in: int, comparer$in: ref)
{
  var index: int where InRange(index, System.Int32);
  var count: int where InRange(count, System.Int32);
  var comparer: ref where $Is(comparer, System.Collections.IComparer) && $Heap[comparer, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack1i: int;
  var stack2i: int;
  var stack3o: ref;
  var stack0b: bool;
  var stack0s: struct;

  entry:
    index := index$in;
    count := count$in;
    comparer := comparer$in;
    goto block72556;

  block72556:
    goto block72947;

  block72947:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block72964;

  block72964:
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- copy
    stack1i := index;
    // ----- copy
    stack2i := count;
    // ----- copy
    stack3o := comparer;
    // ----- call
    call System.Array.Sort$System.Array$System.Int32$System.Int32$System.Collections.IComparer(stack0o, stack1i, stack2i, stack3o);
    // ----- branch
    goto block73083;

  block73083:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true73083to73117, false73083to73049;

  true73083to73117:
    assume local2 == stack0o;
    goto block73117;

  false73083to73049:
    assume local2 != stack0o;
    goto block73049;

  block73117:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block73151;

  block73049:
    // ----- is instance
    // ----- branch
    goto true73049to73117, false73049to73168;

  true73049to73117:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block73117;

  false73049to73168:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block73168;

  block73168:
    // ----- branch
    goto block73151;

  block73151:
    // ----- nop
    // ----- branch
    goto block73015;

  block73015:
    // ----- return
    return;
}



procedure System.Array.Sort$System.Array$System.Int32$System.Int32$System.Collections.IComparer(array$in: ref where $Is(array$in, System.Array) && $Heap[array$in, $allocated], index$in: int where InRange(index$in, System.Int32), length$in: int where InRange(length$in, System.Int32), comparer$in: ref where $Is(comparer$in, System.Collections.IComparer) && $Heap[comparer$in, $allocated]);
  // user-declared preconditions
  requires array$in != null;
  requires $Rank(array$in) == 1;
  requires index$in >= $LBound(array$in, 0);
  requires length$in >= 0;
  requires $LBound(array$in, 0) + index$in + length$in <= $Length(array$in);
  // array is peer consistent
  requires array$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[array$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[array$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // array is peer consistent (owner must not be valid)
  requires array$in == null || $Heap[array$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[array$in, $ownerRef], $inv] <: $Heap[array$in, $ownerFrame]) || $Heap[$Heap[array$in, $ownerRef], $localinv] == $BaseClass($Heap[array$in, $ownerFrame]);
  // comparer is peer consistent
  requires comparer$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[comparer$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[comparer$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // comparer is peer consistent (owner must not be valid)
  requires comparer$in == null || $Heap[comparer$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[comparer$in, $ownerRef], $inv] <: $Heap[comparer$in, $ownerFrame]) || $Heap[$Heap[comparer$in, $ownerRef], $localinv] == $BaseClass($Heap[comparer$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.ToArray(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]) returns ($result: ref where $Is($result, RefArray(System.Object, 1)) && $Heap[$result, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // return value is peer consistent
  ensures $result == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // return value is peer consistent (owner must not be valid)
  ensures $result == null || $Heap[$result, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[$result, $ownerRef], $inv] <: $Heap[$result, $ownerFrame]) || $Heap[$Heap[$result, $ownerRef], $localinv] == $BaseClass($Heap[$result, $ownerFrame]);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.ToArray(this: ref) returns ($result: ref)
{
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0i: int;
  var local3: ref where $Is(local3, RefArray(System.Object, 1)) && $Heap[local3, $allocated];
  var temp2: ref;
  var stack0o: ref;
  var stack1i: int;
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var local4: ref where $Is(local4, RefArray(System.Object, 1)) && $Heap[local4, $allocated];
  var stack0b: bool;
  var stack0s: struct;
  var local6: ref where $Is(local6, RefArray(System.Object, 1)) && $Heap[local6, $allocated];

  entry:
    goto block74154;

  block74154:
    goto block74307;

  block74307:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block74324;

  block74324:
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- new array
    assert 0 <= stack0i;
    havoc temp2;
    assume $Heap[temp2, $allocated] == false && $Length(temp2) == stack0i;
    assume $Heap[$ElementProxy(temp2, -1), $allocated] == false && $ElementProxy(temp2, -1) != temp2 && $ElementProxy(temp2, -1) != null;
    assume temp2 != null;
    assume $typeof(temp2) == RefArray(System.Object, 1);
    assume $Heap[temp2, $ownerRef] == temp2 && $Heap[temp2, $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[$ElementProxy(temp2, -1), $ownerRef] == $ElementProxy(temp2, -1) && $Heap[$ElementProxy(temp2, -1), $ownerFrame] == $PeerGroupPlaceholder;
    assume $Heap[temp2, $inv] == $typeof(temp2) && $Heap[temp2, $localinv] == $typeof(temp2);
    assume (forall $i: int :: ArrayGet($Heap[temp2, $elementsRef], $i) == null);
    $Heap[temp2, $allocated] := true;
    call System.Object..ctor($ElementProxy(temp2, -1));
    local3 := temp2;
    assume IsHeap($Heap);
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 0
    stack1i := 0;
    // ----- copy
    stack2o := local3;
    // ----- load constant 0
    stack3i := 0;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    // ----- copy
    local4 := local3;
    // ----- branch
    goto block74460;

  block74460:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true74460to74494, false74460to74511;

  true74460to74494:
    assume local2 == stack0o;
    goto block74494;

  false74460to74511:
    assume local2 != stack0o;
    goto block74511;

  block74494:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block74426;

  block74511:
    // ----- is instance
    // ----- branch
    goto true74511to74494, false74511to74545;

  true74511to74494:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block74494;

  false74511to74545:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block74545;

  block74545:
    // ----- branch
    goto block74426;

  block74426:
    // ----- nop
    // ----- branch
    goto block74392;

  block74392:
    // ----- copy
    local6 := local4;
    // ----- copy
    stack0o := local4;
    // ----- return
    $result := stack0o;
    return;
}



procedure Collections.ArrayList.ToArray$System.Type$notnull(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], type$in: ref where $IsNotNull(type$in, System.Type) && $Heap[type$in, $allocated]) returns ($result: ref where $Is($result, System.Array) && $Heap[$result, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // type is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[type$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[type$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // type is peer consistent (owner must not be valid)
  requires $Heap[type$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[type$in, $ownerRef], $inv] <: $Heap[type$in, $ownerFrame]) || $Heap[$Heap[type$in, $ownerRef], $localinv] == $BaseClass($Heap[type$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // return value is peer consistent
  ensures $result == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // return value is peer consistent (owner must not be valid)
  ensures $result == null || $Heap[$result, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[$result, $ownerRef], $inv] <: $Heap[$result, $ownerFrame]) || $Heap[$Heap[$result, $ownerRef], $localinv] == $BaseClass($Heap[$result, $ownerFrame]);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.ToArray$System.Type$notnull(this: ref, type$in: ref) returns ($result: ref)
{
  var \type: ref where $IsNotNull(\type, System.Type) && $Heap[\type, $allocated];
  var temp0: ref;
  var stack1s: struct;
  var stack1o: ref;
  var temp1: exposeVersionType;
  var local2: ref where $Is(local2, System.Exception) && $Heap[local2, $allocated];
  var stack0o: ref;
  var stack1i: int;
  var local3: ref where $Is(local3, System.Array) && $Heap[local3, $allocated];
  var stack2o: ref;
  var stack3i: int;
  var stack4i: int;
  var local4: ref where $Is(local4, System.Array) && $Heap[local4, $allocated];
  var stack0b: bool;
  var stack0s: struct;
  var local6: ref where $Is(local6, System.Array) && $Heap[local6, $allocated];

  entry:
    \type := type$in;
    goto block75701;

  block75701:
    goto block75905;

  block75905:
    // ----- nop
    // ----- FrameGuard processing
    temp0 := this;
    // ----- load token
    havoc stack1s;
    assume $IsTokenForType(stack1s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack1o := TypeObject(Collections.ArrayList);
    // ----- local unpack
    assert temp0 != null;
    assert ($Heap[temp0, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[temp0, $ownerRef], $inv] <: $Heap[temp0, $ownerFrame]) || $Heap[$Heap[temp0, $ownerRef], $localinv] == $BaseClass($Heap[temp0, $ownerFrame])) && $Heap[temp0, $inv] <: Collections.ArrayList && $Heap[temp0, $localinv] == $typeof(temp0);
    $Heap[temp0, $localinv] := System.Object;
    havoc temp1;
    $Heap[temp0, $exposeVersion] := temp1;
    assume IsHeap($Heap);
    local2 := null;
    goto block75922;

  block75922:
    // ----- copy
    stack0o := \type;
    // ----- load field
    assert this != null;
    stack1i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    call local3 := System.Array.CreateInstance$System.Type$notnull$System.Int32(stack0o, stack1i);
    // ----- load field
    assert this != null;
    stack0o := $Heap[this, Collections.ArrayList._items];
    // ----- load constant 0
    stack1i := 0;
    // ----- copy
    stack2o := local3;
    // ----- load constant 0
    stack3i := 0;
    // ----- load field
    assert this != null;
    stack4i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    call System.Array.Copy$System.Array$notnull$System.Int32$System.Array$notnull$System.Int32$System.Int32(stack0o, stack1i, stack2o, stack3i, stack4i);
    // ----- copy
    local4 := local3;
    // ----- branch
    goto block76143;

  block76143:
    stack0o := null;
    // ----- binary operator
    // ----- branch
    goto true76143to76075, false76143to76058;

  true76143to76075:
    assume local2 == stack0o;
    goto block76075;

  false76143to76058:
    assume local2 != stack0o;
    goto block76058;

  block76075:
    // ----- load token
    havoc stack0s;
    assume $IsTokenForType(stack0s, Collections.ArrayList);
    // ----- statically resolved GetTypeFromHandle call
    stack0o := TypeObject(Collections.ArrayList);
    // ----- local pack
    assert temp0 != null;
    assert $Heap[temp0, $localinv] == System.Object;
    assert TypeObject($typeof($Heap[temp0, Collections.ArrayList._items])) == TypeObject(RefArray(System.Object, 1));
    assert 0 <= $Heap[temp0, Collections.ArrayList._size];
    assert $Heap[temp0, Collections.ArrayList._size] <= $Length($Heap[temp0, Collections.ArrayList._items]);
    assert (forall ^i: int :: $Heap[temp0, Collections.ArrayList._size] <= ^i && ^i <= $Length($Heap[temp0, Collections.ArrayList._items]) - 1 ==> ArrayGet($Heap[$Heap[temp0, Collections.ArrayList._items], $elementsRef], ^i) == null);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == temp0 && $Heap[$p, $ownerFrame] == Collections.ArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[temp0, $localinv] := $typeof(temp0);
    assume IsHeap($Heap);
    goto block76041;

  block76058:
    // ----- is instance
    // ----- branch
    goto true76058to76075, false76058to76126;

  true76058to76075:
    assume $As(local2, Microsoft.Contracts.ICheckedException) != null;
    goto block76075;

  false76058to76126:
    assume $As(local2, Microsoft.Contracts.ICheckedException) == null;
    goto block76126;

  block76126:
    // ----- branch
    goto block76041;

  block76041:
    // ----- nop
    // ----- branch
    goto block75990;

  block75990:
    // ----- copy
    local6 := local4;
    // ----- copy
    stack0o := local4;
    // ----- return
    $result := stack0o;
    return;
}



procedure System.Array.CreateInstance$System.Type$notnull$System.Int32(elementType$in: ref where $IsNotNull(elementType$in, System.Type) && $Heap[elementType$in, $allocated], length$in: int where InRange(length$in, System.Int32)) returns ($result: ref where $IsNotNull($result, System.Array) && $Heap[$result, $allocated]);
  // user-declared preconditions
  requires elementType$in != null;
  requires length$in >= 0;
  // elementType is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[elementType$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[elementType$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // elementType is peer consistent (owner must not be valid)
  requires $Heap[elementType$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[elementType$in, $ownerRef], $inv] <: $Heap[elementType$in, $ownerFrame]) || $Heap[$Heap[elementType$in, $ownerRef], $localinv] == $BaseClass($Heap[elementType$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $Rank($result) == 1;
  ensures $DimLength($result, 0) == length$in;
  // return value is peer consistent
  ensures (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[$result, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[$result, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // return value is peer consistent (owner must not be valid)
  ensures $Heap[$result, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[$result, $ownerRef], $inv] <: $Heap[$result, $ownerFrame]) || $Heap[$Heap[$result, $ownerRef], $localinv] == $BaseClass($Heap[$result, $ownerFrame]);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.TrimToSize(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList.TrimToSize(this: ref)
{
  var stack0i: int;

  entry:
    goto block77010;

  block77010:
    goto block77078;

  block77078:
    // ----- nop
    // ----- load field
    assert this != null;
    stack0i := $Heap[this, Collections.ArrayList._size];
    // ----- call
    assert this != null;
    call Collections.ArrayList.set_Capacity$System.Int32$.Virtual.$(this, stack0i);
    // ----- return
    return;
}



procedure Collections.ArrayList.set_Capacity$System.Int32$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: int where InRange(value$in, System.Int32));
  // user-declared preconditions
  requires #Collections.ArrayList.get_Count($Heap, this) <= value$in;
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures value$in <= $Length($Heap[this, Collections.ArrayList._items]);
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList..cctor();
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.ArrayList..cctor()
{

  entry:
    goto block77367;

  block77367:
    goto block77401;

  block77401:
    // ----- nop
    // ----- return
    return;
}



axiom Collections.TestArrayList <: Collections.TestArrayList;

axiom $BaseClass(Collections.TestArrayList) == System.Object && AsDirectSubClass(Collections.TestArrayList, $BaseClass(Collections.TestArrayList)) == Collections.TestArrayList;

axiom !$IsImmutable(Collections.TestArrayList) && $AsMutable(Collections.TestArrayList) == Collections.TestArrayList;

// Collections.TestArrayList object invariant
axiom (forall $oi: ref, $h: HeapType :: { $h[$oi, $inv] <: Collections.TestArrayList } IsHeap($h) && $h[$oi, $inv] <: Collections.TestArrayList && $h[$oi, $localinv] != $BaseClass(Collections.TestArrayList) ==> true);

procedure Collections.TestArrayList.Main$System.String.array(args$in: ref where $Is(args$in, RefArray(System.String, 1)) && $Heap[args$in, $allocated]);
  // args is peer consistent
  requires args$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[args$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[args$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // args is peer consistent (owner must not be valid)
  requires args$in == null || $Heap[args$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[args$in, $ownerRef], $inv] <: $Heap[args$in, $ownerFrame]) || $Heap[$Heap[args$in, $ownerRef], $localinv] == $BaseClass($Heap[args$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.TestArrayList.Main$System.String.array(args$in: ref)
{
  var args: ref where $Is(args, RefArray(System.String, 1)) && $Heap[args, $allocated];
  var stack50000o: ref;
  var stack0o: ref;
  var local0: ref where $Is(local0, Collections.ArrayList) && $Heap[local0, $allocated];
  var stack1o: ref;
  var a: ref where $Is(a, Collections.ArrayList) && $Heap[a, $allocated];
  var stack0i: int;
  var local6: int where InRange(local6, System.Int32);
  var idx: int where InRange(idx, System.Int32);
  var local15: int where InRange(local15, System.Int32);
  var bs: int where InRange(bs, System.Int32);
  var stack1i: int;
  var local30: int where InRange(local30, System.Int32);
  var r: int where InRange(r, System.Int32);

  entry:
    args := args$in;
    goto block79985;

  block79985:
    goto block82382;

  block82382:
    // ----- new object
    havoc stack50000o;
    assume $Heap[stack50000o, $allocated] == false && stack50000o != null && $typeof(stack50000o) == Collections.ArrayList;
    assume $Heap[stack50000o, $ownerRef] == stack50000o && $Heap[stack50000o, $ownerFrame] == $PeerGroupPlaceholder;
    // ----- call
    assert stack50000o != null;
    call Collections.ArrayList..ctor(stack50000o);
    // ----- copy
    stack0o := stack50000o;
    // ----- copy
    local0 := stack0o;
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Count($Heap, a) == 0;
    goto block80580;

  block80580:
    // ----- nop
    // ----- load constant "apple"
    stack0o := $stringLiteral26;
    // ----- call
    assert local0 != null;
    call stack0i := Collections.ArrayList.Add$System.Object$.Virtual.$(local0, stack0o);
    // ----- load constant "cranberry"
    stack0o := $stringLiteral27;
    // ----- call
    assert local0 != null;
    call stack0i := Collections.ArrayList.Add$System.Object$.Virtual.$(local0, stack0o);
    // ----- load constant "banana"
    stack0o := $stringLiteral28;
    // ----- call
    assert local0 != null;
    call stack0i := Collections.ArrayList.Add$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Count($Heap, a) == 3;
    goto block80818;

  block80818:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 0) == $stringLiteral26;
    goto block82331;

  block82331:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 1) == $stringLiteral27;
    goto block81770;

  block81770:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 2) == $stringLiteral28;
    goto block82178;

  block82178:
    // ----- nop
    // ----- load constant "apple"
    stack0o := $stringLiteral26;
    // ----- call
    assert local0 != null;
    call local6 := Collections.ArrayList.IndexOf$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert idx == 0;
    goto block80512;

  block80512:
    // ----- nop
    // ----- load constant "cranberry"
    stack0o := $stringLiteral27;
    // ----- call
    assert local0 != null;
    call local6 := Collections.ArrayList.IndexOf$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert idx == 1;
    goto block80002;

  block80002:
    // ----- nop
    // ----- load constant "banana"
    stack0o := $stringLiteral28;
    // ----- call
    assert local0 != null;
    call local6 := Collections.ArrayList.IndexOf$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert idx == 2;
    goto block80444;

  block80444:
    // ----- nop
    // ----- load constant "donut"
    stack0o := $stringLiteral43;
    // ----- call
    assert local0 != null;
    call local6 := Collections.ArrayList.IndexOf$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert idx == -1;
    goto block81056;

  block81056:
    // ----- nop
    // ----- call
    assert local0 != null;
    call Collections.ArrayList.Sort$.Virtual.$(local0);
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Count($Heap, a) == 3;
    goto block82586;

  block82586:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 0) == $stringLiteral26;
    goto block80138;

  block80138:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 1) == $stringLiteral28;
    goto block80036;

  block80036:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 2) == $stringLiteral27;
    goto block81668;

  block81668:
    // ----- nop
    // ----- load constant "apple"
    stack0o := $stringLiteral26;
    // ----- call
    assert local0 != null;
    call local15 := Collections.ArrayList.BinarySearch$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert bs == 0;
    goto block80427;

  block80427:
    // ----- nop
    // ----- load constant "banana"
    stack0o := $stringLiteral28;
    // ----- call
    assert local0 != null;
    call local15 := Collections.ArrayList.BinarySearch$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert bs == 1;
    goto block81481;

  block81481:
    // ----- nop
    // ----- load constant "cranberry"
    stack0o := $stringLiteral27;
    // ----- call
    assert local0 != null;
    call local15 := Collections.ArrayList.BinarySearch$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert bs == 2;
    goto block82195;

  block82195:
    // ----- nop
    // ----- load constant "donut"
    stack0o := $stringLiteral43;
    // ----- call
    assert local0 != null;
    call local15 := Collections.ArrayList.BinarySearch$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert bs < 0;
    goto block81158;

  block81158:
    // ----- nop
    // ----- call
    assert local0 != null;
    call Collections.ArrayList.Reverse$.Virtual.$(local0);
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Count($Heap, a) == 3;
    goto block81396;

  block81396:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 2) == $stringLiteral26;
    goto block80257;

  block80257:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 1) == $stringLiteral28;
    goto block80614;

  block80614:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 0) == $stringLiteral27;
    goto block82569;

  block82569:
    // ----- nop
    // ----- load constant "apple"
    stack0o := $stringLiteral26;
    // ----- call
    assert local0 != null;
    call Collections.ArrayList.Remove$System.Object$.Virtual.$(local0, stack0o);
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Count($Heap, a) == 2;
    goto block80546;

  block80546:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 0) == $stringLiteral27;
    goto block80920;

  block80920:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 1) == $stringLiteral28;
    goto block82654;

  block82654:
    // ----- nop
    // ----- load constant 0
    stack0i := 0;
    // ----- call
    assert local0 != null;
    call Collections.ArrayList.RemoveAt$System.Int32$.Virtual.$(local0, stack0i);
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Count($Heap, a) == 1;
    goto block82841;

  block82841:
    // ----- nop
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Item$System.Int32($Heap, a, 0) == $stringLiteral28;
    goto block81889;

  block81889:
    // ----- nop
    // ----- call
    assert local0 != null;
    call Collections.ArrayList.Clear$.Virtual.$(local0);
    // ----- serialized AssertStatement
    assert #Collections.ArrayList.get_Count($Heap, a) == 0;
    goto block80937;

  block80937:
    // ----- nop
    // ----- load constant "carrot"
    stack0o := $stringLiteral68;
    // ----- load constant 3
    stack1i := 3;
    // ----- call
    call stack0o := Collections.ArrayList.Repeat$System.Object$System.Int32(stack0o, stack1i);
    // ----- call
    assert stack0o != null;
    call local30 := Collections.ArrayList.get_Count$.Virtual.$(stack0o, false);
    // ----- serialized AssertStatement
    assert r == 3;
    goto block80359;

  block80359:
    // ----- nop
    // ----- return
    return;
}



procedure Collections.ArrayList.Sort$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.BinarySearch$System.Object$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], value$in: ref where $Is(value$in, System.Object) && $Heap[value$in, $allocated]) returns ($result: int where InRange($result, System.Int32));
  // user-declared preconditions
  requires value$in == null || !($Heap[this, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[this, $ownerFrame] == $Heap[value$in, $ownerFrame]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // value is peer consistent
  requires value$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[value$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[value$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // value is peer consistent (owner must not be valid)
  requires value$in == null || $Heap[value$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[value$in, $ownerRef], $inv] <: $Heap[value$in, $ownerFrame]) || $Heap[$Heap[value$in, $ownerRef], $localinv] == $BaseClass($Heap[value$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures $result < #Collections.ArrayList.get_Count($Heap, this);
  ensures 0 <= $result && $result < #Collections.ArrayList.get_Count($Heap, this) ==> #Collections.ArrayList.get_Item$System.Int32($Heap, this, $result) == value$in;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Reverse$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Remove$System.Object$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated], obj$in: ref where $Is(obj$in, System.Object) && $Heap[obj$in, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  // obj is peer consistent
  requires obj$in == null || (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[obj$in, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[obj$in, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // obj is peer consistent (owner must not be valid)
  requires obj$in == null || $Heap[obj$in, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[obj$in, $ownerRef], $inv] <: $Heap[obj$in, $ownerFrame]) || $Heap[$Heap[obj$in, $ownerRef], $localinv] == $BaseClass($Heap[obj$in, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.ArrayList.Clear$.Virtual.$(this: ref where $IsNotNull(this, Collections.ArrayList) && $Heap[this, $allocated]);
  // target object is peer consistent
  requires (forall $pc: ref :: { $typeof($pc) } { $Heap[$pc, $localinv] } { $Heap[$pc, $inv] } { $Heap[$pc, $ownerFrame] } { $Heap[$pc, $ownerRef] } $pc != null && $Heap[$pc, $allocated] && $Heap[$pc, $ownerRef] == $Heap[this, $ownerRef] && $Heap[$pc, $ownerFrame] == $Heap[this, $ownerFrame] ==> $Heap[$pc, $inv] == $typeof($pc) && $Heap[$pc, $localinv] == $typeof($pc));
  // target object is peer consistent (owner must not be valid)
  requires $Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame]);
  free requires $BeingConstructed == null;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // user-declared postconditions
  ensures #Collections.ArrayList.get_Count($Heap, this) == 0;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && old($o != this || !($typeof(this) <: DeclType($f)) || !$IncludedInModifiesStar($f)) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



procedure Collections.TestArrayList..ctor(this: ref where $IsNotNull(this, Collections.TestArrayList) && $Heap[this, $allocated]);
  // object is fully unpacked:  this.inv == Object
  free requires ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this);
  // nothing is owned by [this,*] and 'this' is alone in its own peer group
  free requires (forall $o: ref :: $o != this ==> $Heap[$o, $ownerRef] != this) && $Heap[this, $ownerRef] == this && $Heap[this, $ownerFrame] == $PeerGroupPlaceholder;
  free requires $BeingConstructed == this;
  free requires $PurityAxiomsCanBeAssumed;
  modifies $Heap, $ActivityIndicator;
  // target object is allocated upon return
  free ensures $Heap[this, $allocated];
  // target object is additively exposable for Collections.TestArrayList
  ensures ($Heap[this, $ownerFrame] == $PeerGroupPlaceholder || !($Heap[$Heap[this, $ownerRef], $inv] <: $Heap[this, $ownerFrame]) || $Heap[$Heap[this, $ownerRef], $localinv] == $BaseClass($Heap[this, $ownerFrame])) && $Heap[this, $inv] == Collections.TestArrayList && $Heap[this, $localinv] == $typeof(this);
  ensures $Heap[this, $ownerRef] == old($Heap)[this, $ownerRef] && $Heap[this, $ownerFrame] == old($Heap)[this, $ownerFrame];
  ensures $Heap[this, $sharingMode] == $SharingMode_Unshared;
  // newly allocated objects are fully valid
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } $o != null && !old($Heap)[$o, $allocated] && $Heap[$o, $allocated] ==> $Heap[$o, $inv] == $typeof($o) && $Heap[$o, $localinv] == $typeof($o));
  // first consistent owner unchanged if its exposeVersion is
  free ensures (forall $o: ref :: { $Heap[$o, $FirstConsistentOwner] } old($Heap)[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] == $Heap[old($Heap)[$o, $FirstConsistentOwner], $exposeVersion] ==> old($Heap)[$o, $FirstConsistentOwner] == $Heap[$o, $FirstConsistentOwner]);
  // frame condition
  ensures (forall<alpha> $o: ref, $f: Field alpha :: { $Heap[$o, $f] } IncludeInMainFrameCondition($f) && $o != null && old($Heap)[$o, $allocated] && (old($Heap)[$o, $ownerFrame] == $PeerGroupPlaceholder || !(old($Heap)[old($Heap)[$o, $ownerRef], $inv] <: old($Heap)[$o, $ownerFrame]) || old($Heap)[old($Heap)[$o, $ownerRef], $localinv] == $BaseClass(old($Heap)[$o, $ownerFrame])) && ($o != this || !(Collections.TestArrayList <: DeclType($f))) && old(true) && old(true) ==> old($Heap)[$o, $f] == $Heap[$o, $f]);
  free ensures $HeapSucc(old($Heap), $Heap);
  // inv/localinv change only in blocks
  free ensures (forall $o: ref :: { $Heap[$o, $localinv] } { $Heap[$o, $inv] } old($Heap)[$o, $allocated] && $o != this ==> old($Heap)[$o, $inv] == $Heap[$o, $inv] && old($Heap)[$o, $localinv] == $Heap[$o, $localinv]);
  free ensures (forall $o: ref :: { $Heap[$o, $allocated] } old($Heap)[$o, $allocated] ==> $Heap[$o, $allocated]) && (forall $ot: ref :: { $Heap[$ot, $ownerFrame] } { $Heap[$ot, $ownerRef] } old($Heap)[$ot, $allocated] && old($Heap)[$ot, $ownerFrame] != $PeerGroupPlaceholder ==> $Heap[$ot, $ownerRef] == old($Heap)[$ot, $ownerRef] && $Heap[$ot, $ownerFrame] == old($Heap)[$ot, $ownerFrame]) && old($Heap)[$BeingConstructed, $NonNullFieldsAreInitialized] == $Heap[$BeingConstructed, $NonNullFieldsAreInitialized];
  free ensures (forall $o: ref :: { $Heap[$o, $sharingMode] } $o == this || old($Heap[$o, $sharingMode]) == $Heap[$o, $sharingMode]);



implementation Collections.TestArrayList..ctor(this: ref)
{

  entry:
    goto block86003;

  block86003:
    goto block86020;

  block86020:
    // ----- call
    assert this != null;
    call System.Object..ctor(this);
    // ----- return
    // ----- translation-inserted post-constructor pack
    assert this != null;
    assert $Heap[this, $inv] == System.Object && $Heap[this, $localinv] == $typeof(this);
    assert (forall $p: ref :: $p != null && $Heap[$p, $allocated] && $Heap[$p, $ownerRef] == this && $Heap[$p, $ownerFrame] == Collections.TestArrayList ==> $Heap[$p, $inv] == $typeof($p) && $Heap[$p, $localinv] == $typeof($p));
    $Heap[this, $inv] := Collections.TestArrayList;
    assume IsHeap($Heap);
    return;
}



const unique $stringLiteral2: ref;

// $stringLiteral2 is allocated, interned, and has the appropriate type and length
axiom $IsNotNull($stringLiteral2, System.String) && $StringLength($stringLiteral2) == 13 && (forall heap: HeapType :: { heap[$stringLiteral2, $allocated] } IsHeap(heap) ==> heap[$stringLiteral2, $allocated]) && (forall heap: HeapType :: { #System.String.IsInterned$System.String$notnull(heap, $stringLiteral2) } IsHeap(heap) ==> #System.String.IsInterned$System.String$notnull(heap, $stringLiteral2) == $stringLiteral2);

const unique $stringLiteral26: ref;

// $stringLiteral26 is allocated, interned, and has the appropriate type and length
axiom $IsNotNull($stringLiteral26, System.String) && $StringLength($stringLiteral26) == 5 && (forall heap: HeapType :: { heap[$stringLiteral26, $allocated] } IsHeap(heap) ==> heap[$stringLiteral26, $allocated]) && (forall heap: HeapType :: { #System.String.IsInterned$System.String$notnull(heap, $stringLiteral26) } IsHeap(heap) ==> #System.String.IsInterned$System.String$notnull(heap, $stringLiteral26) == $stringLiteral26);

const unique $stringLiteral27: ref;

// $stringLiteral27 is allocated, interned, and has the appropriate type and length
axiom $IsNotNull($stringLiteral27, System.String) && $StringLength($stringLiteral27) == 9 && (forall heap: HeapType :: { heap[$stringLiteral27, $allocated] } IsHeap(heap) ==> heap[$stringLiteral27, $allocated]) && (forall heap: HeapType :: { #System.String.IsInterned$System.String$notnull(heap, $stringLiteral27) } IsHeap(heap) ==> #System.String.IsInterned$System.String$notnull(heap, $stringLiteral27) == $stringLiteral27);

const unique $stringLiteral28: ref;

// $stringLiteral28 is allocated, interned, and has the appropriate type and length
axiom $IsNotNull($stringLiteral28, System.String) && $StringLength($stringLiteral28) == 6 && (forall heap: HeapType :: { heap[$stringLiteral28, $allocated] } IsHeap(heap) ==> heap[$stringLiteral28, $allocated]) && (forall heap: HeapType :: { #System.String.IsInterned$System.String$notnull(heap, $stringLiteral28) } IsHeap(heap) ==> #System.String.IsInterned$System.String$notnull(heap, $stringLiteral28) == $stringLiteral28);

const unique $stringLiteral43: ref;

// $stringLiteral43 is allocated, interned, and has the appropriate type and length
axiom $IsNotNull($stringLiteral43, System.String) && $StringLength($stringLiteral43) == 5 && (forall heap: HeapType :: { heap[$stringLiteral43, $allocated] } IsHeap(heap) ==> heap[$stringLiteral43, $allocated]) && (forall heap: HeapType :: { #System.String.IsInterned$System.String$notnull(heap, $stringLiteral43) } IsHeap(heap) ==> #System.String.IsInterned$System.String$notnull(heap, $stringLiteral43) == $stringLiteral43);

const unique $stringLiteral68: ref;

// $stringLiteral68 is allocated, interned, and has the appropriate type and length
axiom $IsNotNull($stringLiteral68, System.String) && $StringLength($stringLiteral68) == 6 && (forall heap: HeapType :: { heap[$stringLiteral68, $allocated] } IsHeap(heap) ==> heap[$stringLiteral68, $allocated]) && (forall heap: HeapType :: { #System.String.IsInterned$System.String$notnull(heap, $stringLiteral68) } IsHeap(heap) ==> #System.String.IsInterned$System.String$notnull(heap, $stringLiteral68) == $stringLiteral68);
