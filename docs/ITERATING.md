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

## Warning: The `spread` method
Note a clash of method names that may drive to confusion:
`Iterable` actually have a `spread` method, but that one have nothing to do with the `spread` method on an `Spreading` chain!
Please, remember that an `Iterable` chain can not spread its results to next step 
(maybe someday this feature is added, but not now).

## Chain start
And what about if the first value already is an iterable? No problem, use the `iterate` top-level:
```
    iterate(initialValue).map(...)....
```
Like other kind of chains, utility methods are provided for most common cases.
Here, the `chainIterate` top-level give you a shortcut for `chain(...).iterate(...)` pattern:
```
    chainIterate(initialValue,methodReturningAnIterable).map(...)...
```

Easy as 1,2,3...

## Iterating methods return types
One detail to keep in mind about the `Iterables` is the return type for its method.
Probably you know the difference between `intermediate` methods and `terminal` methods of streams.
`intermediate` methods generate a new stream, with its contents altered.
`terminal` methods do no generate a stream, but a single value.

Those different kind of methods are also shown in `Iterable` chains, as different return types.
`intermediate` methods (like `map`,`each` or `skip`) generate a new `Iterable` chain step, so you can continue applying `Iterable`methods as needed.
I.e, you can do the following:
```
    ...iterate(methodReturningAnIterable).map(mappingMethod).fold(foldingMethod).skip(numberToSkip)...
```
On the other side, `terminal` methods (like `count`,`find` or `max`) generate a basic `Chain`, so you can apply any chain methods on it.
So the following is good:
```
    ...iterate(methodReturningAnIterable).count(selectingMethod).to(logCountResultMethod)...
```
but next is forbidden: You can not `map` onto a `Integer`
```
    ...iterate(methodReturningAnIterable).count(selectingMethod).map(mappingMethod)...
```

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
 
