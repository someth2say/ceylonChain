# Chaining Callables for Ceylon
[![Build Status](https://travis-ci.org/someth2say/ceylonChain.svg?branch=master)](https://travis-ci.org/someth2say/ceylonChain)

Many times I find myself writing code like the following:
```
Request request = ...;
value params = parseParameters(request);
value validParams = validateParameters(params);
value output = doStuff(validParams);
value result = writeResponse(output);
return result;
```
This is pretty clear, but actually verbose.

Some languages offer fish-head (`|>`) operator, allowing chaining methods`, 
in a fashion that the result for the first one is used as parameter for the second one:
```
return request |> parseParameters |> validateParameters |> doStuff |> writeResponse;
```
Even other other operators are provided to handle more complicated cases (i.e. when nulls are involved).

This library offer emulating this operator, and many others  
(as described in [this page](https://github.com/ceylon/ceylon/issues/6615)), but using only standard Ceylon classes, and the strength of the typechecker.

Sources for can be found at https://github.com/someth2say/ceylonChain

For learning more about **PicoPatterns**, please visit [this](docs/PICOPATTERNS.md) section.

## TL;DR: Usage
First, you need to create the chain (the first chain step). Simply use the `chain` top-level method to start the chain, 
providing the initial value and the first function.
```
value ch = chain(request, parseParameters);
```
`chain` top-level creates a basic chain. See top-level methods on other step classes to find alternative chain starts.
 
Once initial chain object created, more methods can be added to the chain. Basic way for chaining is using the `to` method:
```
value ch = chain(request, parseParameters).to(validateParameters).to(doStuff).to(writeResponse);
```
Again, `to` is just the basic chaining method. Other methods are available depending on the type of chain step.  

After chaining as many steps as necessary, you may need to explicitly execute the chain, so it is evaluated.
This is always done with the `do` method:
```
return chain(request, parseParameters).to(validateParameters).to(doStuff).to(writeResponse).do();
```
And that's all!

## Different types of chaining
As seen, chaining functions is really straightforward. But wise reader can see that this is only the simplest case.
This module offers support for other patterns (each pattern links to detail page):
###### [Chaining]([docs/CHAINING.md)
 Passing one function result to another function, where types match perfectly.
```
     value val1 = method1(initialValue);
     value val2 = method2(val1);
     value val3 = method3(val2);
```
Is rewritten as
```
    value val3 = chain(initialValue, method1).to(method2).to(method3).do();
```
More details 

###### [Teeing](docs/TEEING.md) 
When methods chain fluently, but the return type and value is irrelevant.
```
    value val1 = method1(initialValue);
    methodWithoutSignificantResult(val1);
    value val2 = method2(val1);
```
Is rewritten as
```
   value val2 = chain(initialValue, method1).tee(methodWithoutSignificantResult).to(method2).do();
```
###### [Spreading](docs/SPREADING.md) 
When the further method returns a `Tuple`, that should be spread to the later method.
Given
```
    function method1(Type1 t1, Type2 t2) => ... ;
```
Pattern
```
    [Type1, Type2] val1 = method1(initialValue);
    value val2 = method2(*val1);
```
Is rewritten as
```
   value val2 = spread(initialValue, method1).to(method2).do();
```

###### [Iterating](docs/ITERATING.md) 
When the results for the further are iterable, so you can take advantage of `Iterable` functional methods.
Given
```
    Iterable<...> method1(Type1 t1) => ... ;
```
Pattern
```
    value iterable = method1(initialValue);
    value iterable2 = iterable.map(mappingMethod); // `map` Or any other method on Iterable
    value val3 = methodWorkingOnIterable(iterable2);
 ```
Is rewritten as
 ```
   value val3 = iterate(initialValue,method1).map(mappingMethod).to(methodWorkingOnIterable).do();
 ```
###### [Optional](docs/OPTIONAL.md): 
When parameters for the later function do not match exactly the results for the further function.
I.e. given
```
    Type2? method1(Type1 t1) => ... ;
    Type3 method2(Type2 t2) => ...; // Note this method does not accept `Null` 
```
Pattern
```
    value val1 = method1(initialValue);
    value val2 = if (exists val1) then method2(val1) else null;
```
Is rewritten as
```
   value val2 = chain(initialValue, method1).ifExists(method2).do();
```
There are many kind of optionals, but this module provide the following ones:
- Null safe optionals (the one on the previous example)
- Type retaining optionals
- Type stripping optionals
You can find de details on [Optionals](docs/OPTIONAL.md) page.

## END
This is the end of the basic documentation for this module.
You may want to start a detailed walkthrough. If so, you can start by the [chaining pattern](docs/CHAINING.md). 

# Enjoy!
Don't hesitate using and distributing this library, or getting back to me to any doubts or issues you may have.

