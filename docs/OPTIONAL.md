# Optionals:
This is the last and more complex pattern being covered here.
"Optional" patterns are those patterns where the incomming type (the type returned by previous chain steps) does not match **exactly** the parameter
types for step's function parameters.

Currently, three kind of optional patterns are supported: "Null Safe", "Probing" and "Stripping"
 
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
The main detail here is the outgoing type. If you provide explicit types, the chain here is:
```
   Chain<Type1?> ch1 =  ...to(methodThatMayReturnNull)
   Chain<Type2?> ch2 =  ch1.to(methodThatMayReturnNull).ifExists(methodThatDoesNotAcceptNull);
```
You see? the `Null` have been inserted into the second chain step, even `methodThatDoesNotAcceptNull` does not return a nullable type.

#### Chain start
One can also imagine the situation where the initial value is of a nullable type.
In this situations, the `ifExists` top-level works out:
```
    InitialType|Null initialValue = ...
    value val = ifExists(intialValue, methodThatDoesNotAcceptNull).to(...).do();
```
There is no version for `ifExists` accepting only the initial value (no function).

 
## Probing
Probing steps are the evolution for Null Safe steps, when you realize `Null` is just another Type.
So, if you can write a chain that 'forwards' `Null`s, maybe we can write chains that forward any other type.
That's the intent for `Probing`.
In other words, given
```
    Type1|Type2 method1(ValType val) => ...
    Type3 method2(Type1 t1) => ... 
```
the pattern is:
```
    value val1 = method1(initialValue);
    value val2 = if (is Type1 val1) method2(val1) else val1
```

#### Chain steps
The way to apply the probing pattern is, indeed, with the `probe` keyword:
```
    value ch = chainTo(initialValue,method1).probe(method2);
```
The devil here, like in "Null Safe", is in the types.

When Ceylon's type checker evaluates the sample code in the Probing pattern, types are resolved like the following:
``` 
    Type1|Type2 val1 = method1(initialValue);
    Type3|Type2 val2 = if (is Type1 val1) method2(val1) else val1
```
Looks good!

Let's review the second statement again, this time notating the types in every step:
 ``` 
     Type3|Type2 val2 = if (is Type1 val1) 
                            /* here `val1` is asserted to have type 'Type1' */ 
                            method2(val1)  
                        else 
                            /* here `val1` type is `Type1|Type2 & ~Type1' (~ means 'not', complementary type) */
                            /* a bit of logic, and its type is just simplified to `Type2` */
                            val1
 ```
Unluckily, the type checker uses a trick not available to the compiler: complementary types.
This makes Probing steps unable to include the `~Type1` part into the equation, and hence 
**the incomming type is allways part for the outgoing part.**

So, making types explicit in the chain, you will find the following:
```
    Chain<Type1|Type2> ch1 = chain(initialValue,method1);
    Chain<Type1|Type2|Type3> ch2 = ch1.probe(method2);
``` 
This is not a big deal when the final type for the chain is not relevant, or the amount of chain steps is low.
 Even worse, note that the types will become more and more complex through the chain, making `probe` more likely to be used,
 and complicating the types more and more.
 
 So, if you actually need to be strict with types, probing steps are not for you, and you probably need to take a look to [stripping](STRIPPING.md) chains.

#### Chain start
Indeed, there are Probing initial steps with the `probe` top-level method.
```
    Type1|Type2 initialValue = ...
    value ch = probe(initialValue,method2)...;
```
 
## END
This is not the end for Optional patterns.
[Next chapter](STRIPPING.md) introduces a new kind of optional steps: those stripping types apart, 
and working each part separately.  