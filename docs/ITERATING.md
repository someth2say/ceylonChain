# Iterating:
 Nowadays, `Iterable`s are trending topics.
 They represent one of the basic trunks for "functional programing": `Iterable` provide many operations to apply functions to 
 its contents, hiding from the developer the details on how those functions are applied.
 Typical examples are the `map` methods, that (lazily) applies a transforming function to all elements, or `fold`, that computes 
 a value based on all the elements for the stream. In Java, this is one of the first samples I found on the web:
```
myList
    .stream()
    .filter(s -> s.startsWith("c"))
    .map(String::toUpperCase)
    .sorted()
    .forEach(System.out::println);
```
Kind of looks like a chain, isn't it? An start point (`myList`), with many methods applied to it, 
most of them with a function-reference parameter.
The picopattern we are looking at is a mix of the [chaining]([docs/CHAINING.md) pattern `Iterable`s: 
``` 
    Iterable<...> iterable = methodReturningAnIterable(initialValue);
    value mappedIterable = iterable.map(mappingMethod); // Or any other method rather than `map`
    value next = methodWorkingOnIterable(mappedIterable);
``` 
 
## Chain steps
Like the [spreading](docs/SPREADING.md) pattern, the this pattern consists of two steps.
First one, defining a method that returns an `Iterable`.
Second, using `Iterable` capabilities on the incomming iterable (but without loosing the chaining capabilities!).

So, for the first step, we will be using the `iterate` top-level method:
```
    chain(...).iterate(methodReturningAnIterable)...
```
Then, now we are allowed to use the capabilities offered by `Iterable`s:
```
    chain(...).iterate(methodReturningAnIterable).map(mappingMethod)...
```
Note that you may not always want to apply a method to the contents for the stream, but sometimes you just want to 
pass *the stream* to a method. 
Not a big deal. An `Iterable` is just another type, so you can pass it by using the `to` method.
```
    chain(...).iterate(methodReturningAnIterable).map(mappingMethod).to(methodWorkingOnIterable)...
```    

###### Iterables and Spreading
Do you know any function transforming an `Iterable` to a `Tuple`?
I do not... but this does not mean it can't exist.
Let's guess you have something like the following:
``` 
    Iterable<...> iterable = methodReturningAnIterable(initialValue);
    [Type1, Type2...] tuple = iterableToTupleMethod(iterable)
    value val = methodWithManyParameters(*tuple);
``` 
Can it be accomplished with chains?
Sure, it can. And you need no extra methods for doing so.
Just need yo realize this pattern implies using the `Iterable` as a simple type! No `Iterable` feature is being used here!
So you just need to use the `spread...to` pattern:
```
    chain(...).to(methodReturningAnIterable).spread(iterableToTupleMethod).to(methodWithManyParameters);
```
Being true, if you actually feel the need for using the `iterate` method, you can do so!
```
    chain(...).iterate(methodReturningAnIterable).spread(iterableToTupleMethod).to(methodWithManyParameters);
```
An `Iterable` chain is still a `Chaining` chain, so you can always chain the basic way. 

## Chain start
And what about if the first method already returns an iterable? No problem, use the `iterate` top-level:
```
    iterate(initialValue,methodReturningAnIterable)....
```
Or the `iterates` method, if your initial value need to be spread onto the initial function!

## Iterating methods return types























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
 
 
[Next chapter](ITERATING.md) will show you how to merge chains with the trending 
topic of `Streams` and `Iterables` (someone said functional programming? :)
