# Optionals:
This is the last and more complex pattern being covered here.
"Optional" patterns are those patterns where:
- When the incomming type (the type produced by the previous chain step) satisfy this step's function parameter type, then
function is applied, and it's result is sent forward the chain.
- Else the incomming value is sent forward the chain, without any change.

Note that this definition says nothing about the outgoing type (the type for the value being forwarded)! 
This gives us some degrees of freedom.
Depending on how incomming type and how we relate it to the outgoing type, we can find three patterns.
 
## Null Safe
The simplest optional picopattern is when the only difference between the incomming type and function parameter type is the `Null` type:
```
   value nullable = methodThatMayReturnNull(val);
   value nextNullable = if (exists nullable) then methodThatDoesNotAcceptNull(nullable) else null;
```

#### Chain steps
Keyword here is `ifExists` (as a memo for `if (exists ...` pattern).
So, given a first function that returns a nullable type, and a second function that accepts the non-nullable version:
```
    Type1? methodThatMayReturnNull(ValType val) => ...
    Type2  methodThatDoesNotAcceptNull(Type1 t1) => ... // Note it accepts `Type1`, not `Type1?`
```
You can write it with the 'null safe' chain:
```
    ...to(methodThatMayReturnNull).ifExist(methodThatDoesNotAcceptNull)...
```
The tricky detail here is the outgoing type. If you provide explicit types, the chain here is:
```
   Chain<Type1?> ch1 =  ...to(methodThatMayReturnNull)
   Chain<Type2?> ch2 =  ch1.to(methodThatMayReturnNull).ifExists(methodThatDoesNotAcceptNull);
```
You see? the `Null` have been inserted into the second chain, even `methodThatDoesNotAcceptNull` does not return a nullable type.

#### Chain start
One can also imagine the situation where the initial value is of a nullable type.
In this situations, the `ifExists` top-level works out:
```
    InitialType|Null initialValue = ...
    value val = ifExists(intialValue, methodThatDoesNotAcceptNull).to(...).do();
```

Weirder, but possible, the situation where initial function accepts multiple parameters, but the whole set of parameters is optional:
```
   [Type1,Type2...]? initialParameterList = ...
   function initialFunction(Type1 t1, Type2 t2, ....) =>
```
If this happens (really?), you should use the `ifExistss` top level:
```
    [Type1,Type2...]|Null initialValue = ...
    value val = ifExistss(intialValue, initialFunction).to(...).do();
```

## Probing
Let's add an idea to previous pattern: Null Safe pattern just flows the `Null` type forward over the chain. 
But `Null` is just another type in Ceylon, nothing actually special; so... why can't I use any type? 
Maybe I just can make exceptions returned by functions flow over, or any other type!

That is the target for the "Probing Pattern": "probe" (meaning try) if the incomming type can be used by the current function,
or just let it flow else.
 
But there is a hidden monster inside this. 

Let's take a look at the Probing pattern without using chains:
``` 
    Type1|Type2 methodThatMayReturnManyTypes(ValType val) => ...
    Type3 methodThatJustAcceptsType1(Type1 val1) => ...
 
    Type1|Type2 val1 = methodThatMayReturnManyTypes(val);
    value val2 = if (is Type1 val1) then methodThatJustAcceptsType1(val1) else val1;
```
Question: what is the type for `val2`?
If you try this, Ceylon's type checker will say `Type2|Type3`. Good!
 


#### Chain steps

#### Chain start


## Forcing

#### Chain steps

#### Chain start



## END
Being true, `Iterable` chain steps are not actually needed at all. 
The same behaviour can be reach by using Ceylon's `suffle` top-level method, to transform functions *onto* `Iterables` to functions *receiving* `Iterables`.
I.e. the `map` function of an iterable chain looks like the following:
```
    shared IterableChain<{NewReturn*},NewReturn> map<NewReturn>(NewReturn(Element) operation) 
        => Iterating<{NewReturn*},Return,NewReturn>(this, shuffle(Return.map<NewReturn>)(operation));
```
 You see?  `shuffle(Return.map<NewReturn>)(operation)` just transforms the `map` method from a function accepting an "operation" and returning an `Iterable`
 to a function that accepts an `Iterable` to another function that accepts an "operation" and returns an `Iterable`.
 May seem tricky, but don't worry, `Iterable` chain steps already does it for you.
 
In [Next chapter](OPTIONAL.md) we will talk what happens when return type does not **exactly** match the following function's parameters?
Those are the `optional` patterns.
 
