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

## Usage
Simply use the `chain` top-level method to start a chained method call, providing initial value and a function reference.
```
value ch = chain(request, parseParameters);
```
This will create a initial "chain" object, that allows to chain other steps. Basic way for chaining is using the `to` method:

```
value ch = chain(request, parseParameters).to(validateParameters).to(doStuff).to(writeResponse);
```

After chaining as many steps as necessary, you need to explicitly execute the chain, with the `do` method:
```
return chain(request, parseParameters).to(validateParameters).to(doStuff).to(writeResponse).do();
```

## Different types of chaining
As seen, chaining functions is really straightforward. But wise reader can see that this is only the simplest case.
This module offers support for other picopatterns:
- Chaining: the one you already saw.
 Consist about passing one function result to another function, where types match perfectly.
- Teeing: When methods chain fluently, but the return type and value is irrelevant.
- Spreading: When the further method returns a `Tuple`, that should be spread to the later method.
- Iterating: When the results for the further are iterable, so you can take advantage of `Iterable` functional methods.
- Optional: When parameters for the later function do not match exactly the results for the further function.



### Spreading chain
The most common situation that does not fit in previous schema is when functions to be chained do need more than one parameters:
```
Request request = ...;
Encoding encoding = ...;
Params params = parseParameters(request,encoding);
[Params, Params] validAndInvalidParams = validateParameters(params);
value output = doStuff(validParams,invalidParams);
Result result = writeResponse(output);
return result;
```
In this example, both `parseParameters` and `doStuff` require multiple parameters.

As `parseParameters` needs to be chain start, we need a new "start" top-level method: `starts` (be aware of the "s" at the end, you will see it in many places):
```
value ch = chains([request,encoding], parseParameters)...
```
Note all parameters to be passed to the function are wrapped into a `Tuple`. This tuple will be `spread` into the function arguments, as described in [Ceylon docs](https://ceylon-lang.org/documentation/reference/expression/positional-argument-list/#spread_arguments)

About `doStuff`, `validateParameters` method already provided a `Tuple` that can be spread into `doStuff`. We only need to indicate that this tuple should be spread.
For doing so, a new chain method appears: `spread`: The `spread` method will **spread** the return type of it's function **to** the next chain step (read "spread this to that").
```
return chains([request,encoding], parseParameters).spread(validateParameters).to(doStuff).to(writeResponse).do()
```

There is an special case worth to be commented.
What if you need to spread many consecutive functions? I.e:
```
Request request = ...;
Params params = parseParameters(request);
[Params, Params] params = validateParameters(params);
[Output, Params] output = doStuff(params[0],param[1]);
Result result = writeResponse(output[0], output[1]);
return result;
```
The `to` method is just for "normal" function chaining, does not add the spreading capability. Hence, `spread(...).to(...)` won't work.
No worries,you can spread again with the `spread` method:  `spread(...).spread(...).to(...)`:
```
return chain(request, parseParameters).spread(validateParameters).spread(doStuff).to(writeResponse).do()
```

Finally, remember you can even start a chain with a method that should be spread, by `spread` and `spreads` top-levels:
```
Request request = ...;
[Params,Encoding] params = parseParameters(request);
[Params, Params] params = validateParameters(params[0], params[1]);
[Output, Params] output = doStuff(params[0],param[1]);
Result result = writeResponse(output);
return result;
```
Will be shown as:
```
return spread(request, parseParameters).spread(validateParameters).spread(doStuff).to(writeResponse).do()
```
Or, when multiple initial parameters:
```
Request request = ...;
Encoding encoding = ...;
[Params,Encoding] params = parseParameters(request, encoding);
[Params, Params] params = validateParameters(params[0], params[1]);
[Output, Params] output = doStuff(params[0],param[1]);
Result result = writeResponse(output);
return result;
```
Goes to:
```
return spreads([request,encoding], parseParameters).spread(validateParameters).spread(doStuff).to(writeResponse).do()
```

### Teeing chain
Sometimes, intermediate values are used for several functions, or just need the intermediate value to be passed to a function, but no return is expected.
```
Request request = ...;
value params = parseParameters(request);
validateParameters(params); // Let's say this just throws if params are invalid. No return type expected.
value output = doStuff(params);
value result = writeResponse(output);
return result;
```

For sure, you can wrap the `validateParameters` function with another function that returns the same input parameter, and then use the new function for chaining:
```
    function validate(Params params) { validateParameters(params); return params; }
    return chain(request, parseParameters).to(validate).to(doStuff).to(writeResponse).do();
```

This works, no issues. But it is tedious having to write functions just to return the input parameters.
So `tee` chain steps will do it for you:
```
    return chain(request, parseParameters).tee(validateParameters).to(doStuff).to(writeResponse).do();
```

`tee` chain steps just get the incomming parameters, apply the function, and return the same parameters.

Even you can use them to split the chain into two chain paths:
```
function validate(Params params) => chain(params, validateParameter).to(logValidation).to(andSomeMoreStuff).do();
return chain(request, parseParameters).tee(validate).to(doStuff).to(writeResponse).do();
```
This way, you can create some kind of "sub-chain", that will be executed on `tee` step, but after done, original `params` will be used to continue the chain.

### Iterating chain
Nowadays, *streams* and *functional programming* are trending topics.

The idea about `streams` is that data (the streams) can accept *method references* (from *FP*),
 so those methods do actually work out the data in a "standard" way, many times creating a new instance of the data.
 So you can say this approach is just "chaining" data instances, by providing *method references* on each step.

`Chains`, on the other way, face this same concept from the perspective of `functions`, instead of `data`.
 Instead of chaining data instances, we are chaining `functions`.

Concepts are transverse.

Then, can you use both? Sure you can, but by default, seems not very useful:

```
Request request = ...;
{Params*} params = parseParameters(request);
{Params*} validParams = params.map(validate);
value output = doStuff(validParams);
value result = writeResponse(output);
return result;
```
Is transformed to:
```
return chain(chain(request,parseParameters).do().map(validate),doStuff).to(writeResponse).do();
```
As you can see, you need to "leave" the chain in order to apply the `map` function, and then use its result to re-start the chain. Too bad.

In fact, there is a trick in Ceylon language that can be used to avoid leaving the chain: the [`shuffle`](https://modules.ceylon-lang.org/repo/1/ceylon/language/1.3.2/module-doc/api/index.html#shuffle) top-level.
This top-level method allow to transform a function *on a type instance* to a function that *receives an instance* as a parameter.
So previous can be rewritten to:
```
return chain(request,parseParameters).to(shuffle(map<Params>)(validate)).to(doStuff).to(writeResponse).do();
```

Not bad! But still a bit cumbersome.
So Iterating chains come to save the day, and they will do the `shuffle` work for you.
For creating a chain step that can be used like an stream, just use the `iterate` method (or the `iterate`/`iterates` top-level for a chain start):
```
return iterate(request,parseParameters).map(validate).to(doStuff).to(writeResponse).do();
```
Et voilà! All methods that can be used onto an `Iterable`, can be used onto the chain step, but without the need of leaving the chain: `fold` , `every`, `contains`... no limits!

 :point_up:
 Some methods, like `map`,`narrow`,`filter`... when used onto an `Iterable` do actually return another `Iterable`.
 Those same methods, when used onto an `iterate` chain step, will also return another `iterate` chain step! This allows you to write things like:
 ```
    ...iterate(...).map(...).filter(...)...
 ```

 Some other `Iterable` methods (some times called "collecting" methods), do not return a stream, but "simple" values: `any`, `find`,`shorterThan`...
 Those, when applied onto a `iterate` chain step will provide a new basic chain step, whose return type will be the same than the original method.

:warning:
The `spread` method of `Iterable` clashes with the `spread` method of a chain step over the next step.
For avoiding this, `spread` method of `iterate` chain steps have been renamed to `spreadIterable`.

### Probing and forcing
Sometimes (many times) functions do not match completely. I.e. many times, a function can return a nullable type (`Element|Null`, or just `Element?`),
but the next function to be chained just accept non-nullable types (say `Element`).
The canonical example for this is:
```
Element? elemOrNot = getElement(...);
Partial? partialOrNot = if (exists element = elementOrNot) then doSomethingWithElement(element) else null;
Result? result = if (exists partial = partialOrNot) then doSomethingWithPartial(partial) else null;
```
You see, `Null` keeps on flowing down to each function, forcing an `exists` check to be included every time.

Getting back to our previous sample functions, let's present the following:
```
Request request = ...;
Params params = parseParameters(request);
Params? validParams = validateParameters(params); // Now, validate return `Null` if params are not valid.
Output output = doStuff(validParams); // Error, doStuff accepts Params, not Params?
Result result = writeResponse(output);
return result;
```
How can we express that using chains? `probe` come to save the day.
`probe` chain steps will apply incoming values to the provided functions **only if** its type match. 
Else, the incoming value will just flow to next chain steps.

So, in the example, we can just `probe` to apply `validParams` to `doStuff`, and the chain will do the trick:
```
return chain(request, parseParameters).to(validateParameters).probe(doStuff).probe(writeResponse).do()
```
If parameters are valid, `validateParameters` will return an instance of `Params`, that will flow to `doStuff`.
 But if parameters are not valid, `validateParameters` will return `null`. As `Null` is not accepted by `doStuff`, this function will not be used, and `null` will flow to `writeResponse`.
Because `null` can also flow to `writeResponse`, but it does not accept `Null`, `probe` is also needed in that chain step.

Being true, the chain just shown is not completely equivalent to the non-chaining version. The actual return type for the whole chain is not `Result`, 
but `Null|Params|Output|Result`! WTF! 
Clever reader will say: "Hey! Pure Ceylon code can actually check the type, and downcast to `Result`!"
And you are right... partially. Ceylon can do that because either TypeChecker can "remove" types from an union type, or the developer is smart enough 
  to remove the types manually (via `assert is`).  
But the compiler can not. There is no way to say "assert(is Params|Null & ~Null)" (meaning ~ the type negation or complementary types).
Hence, the outcoming type for  a `probe` step will always be its incoming type **plus** (meaning "union to") the return type for the function.
 
"Ok. You are right, you can not remove the matched type. So why don't you just assert on the type?"
Sure... are you able to tell me (from the point of view of the library) the type I need to assert to?
 Think it a bit, and you will find you can not decide the type you need to assert to, in a general way.

But...

You can not decide the type, but you can `force` it.






  





Also, the result for the whole chain changed. Previously, the `result` may never be `null`, but with this approach, `null` can lurk to the end of the chain. Hence, now `result` can be null!

#### Advanced probing
Probing `null` values is just one usage for `probe`. But `probe` can also be used for more advanced situations.

Let's say that `validateParameters` can return the *union type* `Params|InvalidParametersException`. Not that uncommon in Ceylon that exceptional cases are handled just as united return types.
No problem for `probe`!
In fact, `probe` will check if the *run time* return type for the previous chain steps do match the type accepted by its function. If types mach, function will be applied. Else, the previous chain step's
value will be passed by.

Let's rewrite the previous example, with exception handling!
```
Request request = ...;
Params params = parseParameters(request);
Params|InvalidParametersException validParams = validateParameters(params);
Output output = doStuff(validParams); // Error, doStuff accepts Params, not Params|InvalidParametersException
Result result = writeResponse(output);
return result;
```
Will be:
```
 return chain(request, parseParameters).to(validateParameters).probe(doStuff).probe(writeResponse).do()
```
Hey! this is exactly the same code shown before!
Yes, it is. It does not matter what parameter types you are using, 'Null' or whatever, probe will handle them properly.

More useful tricks : What if you actually want to handle the exception, instead of just letting it pass by?
No problem, just add another step in the chain:
```
 Result catchException(InvalidParametersException e) => ... ; // build default Result in case of exception
 return chain(request, parseParameters).to(validateParameters).probe(doStuff).probe(writeResponse).probe(cathException).do()
```
And this way you can react to the exception.

But we are not done here! You can even catch the exception in earlier places, and provide a default value for the chain to continue with:
```
 Params catchException(InvalidParametersException e) => ... ; // build default Params in case of exception
 return chain(request, parseParameters).to(validateParameters).probe(cathException).probe(doStuff).probe(writeResponse).do()
```
If an exception is returned by `validateParameters`, it will be catched by `catchException`, and default parameters will flow to `doStuff`.
If no exception is returned by `validateParameters`, it won't match `catchException` parameter types, and hence valid `Params` will flow directly to `doStuff`.
Almost magic!

:warning:
Probing chain steps do not validate the used function parameters are somehow related to incoming parameters!
So you can add to a chain useless functions that will never be matched! Be careful!

##### Gotcha:
**Probing chain steps (both initial and intermediate) will not "absorb" a matched type.**

Say you use a `probe` step that with an incoming type `A|B` and a function of type `A(B)`.<br>
  At **run time**, when `B` incomes to the step, it will match, function will be applied, and `A` will be returned. Good.<br>
  But at **compile time**, return type for a `probe` chain step will always be the *union* of both *incoming* type and the type returned by the function.<br>
  That is: `A|B` (the incoming type) union `A` (the returned type for the function) = `(A|B)|A` = `(A|B)`.
  Despite sometimes (most of the time?) the objective of using `prove` is to handle some of the cases for the chain, the handled cases are not "removed" from the chain return type.
If you actually need to "absorb" a type when handling it, you will need to use a construct like the following one:
```
 Params catchException(Params|InvalidParametersException paramsOrException) => if (is InvalidParametersException paramsOrException) then buildDefaultParams(...) else paramsOrException;
 return chain(request, parseParameters).to(validateParameters).to(cathException).to(doStuff).to(writeResponse).do()
```
Maybe some day this construct can be directly included into the chain to save your code :)

### Alternative to probing: Option.
`probe` chain steps are type-safe, but may really mess things up when the amount of types keep increasing.
Wouldn't it be good to have a way to 'decrease' the amount of types?
Bad news that, actually, there is no type-safe way to do so.
Good news that you have a type-unsafe way: the `force` chain steps.

`force` chain steps are designed to translate a sub-type for the incoming type to another sub-type for the incoming type.
 Clearer with an example: Say you have an incoming type `A|B`. You can use `force` to transform `A` to `B`. Then, the outgoing type will be `A|A`, that is just `A`.

Now, a real life example. Let's get back to the request example, to the point where validating parameters return `Params|InvalidParameterException`:
```
Request request = ...;
Params params = parseParameters(request);
Params|InvalidParametersException validParams = validateParameters(params);
Output output = doStuff(validParams); // Error, doStuff accepts Params, not Params|InvalidParametersException
Result result = writeResponse(output);
return result;
```
By using `force` chain steps, this can be rewritten to:
```
 Params buildDefaultParams(InvalidParametersException ipe) => Params(...);
 return chain(request, parseParameters).to(validateParameters).force(buildDefaultParams).to(doStuff).to(writeResponse).do()
```
Here, `buildDefaultParams` will just generate default parameters in case request parameters where invalid.
Note that the return type for `buildDefaultParams` is `Params`. Hence, the outcoming type for the `.force(buildDefaultParams)` step is `Params|Params`, that is just `Params`.

Let's show another typical usage for `force`, this time with null values:
```
    String str = ..
    Character? start = str.first;
    if (is Null start) {
        Character default = ' ';
        foo(default);
    } else {
        foo(int)
    }
```
Can be rewritten as:
```
    chain(str,String.first).force((Null n)=>' ').to(foo).do();
```

Sounds a great way for the "try or default" pattern, isn't it?
Unluckily, not that easy. `force` steps do have some restrictions:

- Remember that the outgoing type for a `force` step with a function with type `A(B)` is the union for the incoming type (say `Z`) with the function's return type (`A`).
  So, if `A` and `Z` are not somehow covering each other, you will simply get the outcoming type `A|Z`.
   This is not necessary bad, but maybe not the thing you will expect.
- `force` steps **require** the incomming type `Z` to satisfy united function types `A|B`. In other words, whatever `Z` is,
  either it should satisfy `A` (and then it will be transformed to `B`), or should satisfy `B` (then `Z` will be returned).
  This means you should pick functions carefully. You can not use a function like `Integer(Boolean)` if the incomming type is `Boolean`: `Boolean` does not satisfy `Integer`!
- What if the function you use have a return type **incompatible** with the incomming type? Then, **`force` will throw an `AssertionError` on runtime!**.
  That's why I insist: `force` is not type-safe.


## Caveats
There are several points of improvement on this code:
- There is a (minimal) memory footprint for using this construct, opposed to a native `|>` operator that is just syntax sugar.
- As already said, `probe` steps do not actually remove the type when matched, nor `force` is actually type safe. Maybe someday...


# Enjoy!
Don't hesitate using and distributing this library, or getting back to me to any doubts or issues you may have.

