# Stripping:
Many places I found that a function returns an Union Type (`A|B|...|Z`),and then each part is worked out in separate functions.
The pattern is the following:
```
    Type1|Type2 val1 = method(val);
    Type3|Type4 val2 = if (is Type1 val1) 
                           method3(val1) 
                       else 
                           method4(val1);
```
There are many variants for this pattern (i.e. using just a single `methodN`, or the `case` statement), 
but those are just variations with the same semantics: splitting a union type into parts and apply functions onto each part.
 
#### Chain steps
This functionality, like `Iterating` or `Spreading`, have a pre-requisite: the incoming type should be "splittable". In other words,
 the incomming type should be an Union Type.
So this is also a two-step pattern.
Given 
```
    Type1|...|TypeN method(Value val) => ...
```
The first step is created through the `strip` keyword:
```
    ...strip<Left,Right>(method)...
```
As you can see, here type parameters are not optional, nor can be inferred. 
`Left` and `Right` types should cover the return type for the function. That is, any type in `Type1|...|TypeN` should be 
 covered by either `Left` or `Right` (or both, in witch case it is considered to be covered by `Left`).
So those type "strip" the return type in two.

After the `strip`, three new operations became available: `lTo`, `rTo` and `lrTo`.
`lTo` accepts a function, that will be applied when the incomming value satisfies `Left`.
So you can write:
```
    Type1|...|TypeN method(Value val) => ...
    NewLeft methodOnLeft(Left left) => ...
    value ch = chain(...)...strip<Left,Right>(method).lTo(methodOnLeft).do();
```
Can you guess what will be the type for `ch` here? 
```
    NewLeft|Right ch = chain(...)...strip<Left,Right>(method).lTo(methodOnLeft).do();
```
`methodOnLeft` is only applied (and hence changing types) on a match for `Left` type. 

Symmetrically, `rTo` only matches the `Right` type:
```
    Type1|...|TypeN method(Value val) => ...
    NewRight methodOnRight(Right right) => ...
    Left|NewRight ch = chain(...)...strip<Left,Right>(method).rTo(methodOnRight).do();
```

Finally, `lrTo` allows to change both types at once:
```
    Type1|...|TypeN method(Value val) => ...
    NewLeft methodOnLeft(Left left) => ...
    NewRight methodOnRight(Right right) => ...
    NewLeft|NewRight ch = chain(...)...strip<Left,Right>(method).lrTo(methodOnLeft,methodOnRight).do();
```

#### Chain start
Indeed if your first function returns an Union Type, you can strip it from the beginning, with `strip` and `strips` methods.
You just need to provide all types (even the type for the initial argument):
```
    Value initialValue = ...
    Type1|...|TypeN method(Value val) => ...
    NewRight methodOnRight(Right right) => ...
    Left|NewRight ch = strip<Left,Right,Value>(initialValue, method).rTo(methodOnRight).do();
```
 
 
 
 
## END
This is not the end for Optional patterns.
[Next chapter](STRIPPING.md) introduces a new kind of optional steps: those stripping types apart, 
and working each part separately.  



