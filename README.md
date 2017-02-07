# Chaining Callables for Ceylon [![Build Status](https://travis-ci.org/someth2say/ceylonChain.svg?branch=master)](https://travis-ci.org/someth2say/ceylonChain)

Many times I find myself writing code like the following:
```
Request request = ...;
value params = parseParameters(request);
value paramsAgain = validateParameters(params);
value output = doStuff(paramsAgain);
writeResponse(output);
```

This is pretty clear, but much verbose.
Some languages offer headfish (`|>`) operator, allowing chaining `methods`, in a fashion that the result for the first one is used as parameter for the second one.
This library offer emulating this operator (as described in https://github.com/ceylon/ceylon/issues/6615, but using only standard Ceylon classes, and the strength of the typechecker.

Sources for Chaining Callables can be retrieved from https://github.com/someth2say/ceylonChain

## Usage
Simply use the `chain` top-level method to start a chained method call, and provide a function reference.
```
IChainable<Integer,String> stringSizeChain = chain(String.size);
```

This will create a `IChainable` object, that allows to chain other methods in different flavours. Chain more function references by using the provided methods:
- `\ithen`: Headfish operator `|>`. Invokes the first function, and then passes its results to the second function.
- `thenOptionally`: Crying-headfish operator `|?>`. Also forwards the value from the first method to the second, but only if this value is not `null`. If first function returned `null`, then second function is not evaluated, and `null` is returned.
- `thenSpreadable`: Dead-headfish opeator `|*>`. It works with methods that accept several parameters, instead of a single one. Result from first method (should be an iterable) is spread, and sent to the second method as its arguments.
- `with`: This method finalizes the chain, by providing its parameters, and evaluating functions in the right order. You can understand it as the invocation operation.

## Basic chaining
Having the initial chain step, you can go on providing the following steps, via `\ithen`, `thenOptionally` or `thenSpreadable`.
Once all steps are declared, `IChainable` can be passed by to other methods, finally invoked.
Invocation is done with the `with` method. This will accept the same arguments as the callable used in the creation for the first step.

### Basic chaining sample
```
Request request = ...;
value params = parseParameters(request);
value paramsAgain = validateParameters(params);
value output = doStuff(paramsAgain);
writeResponse(output);
```
Can be rewritten as
```
Request request = ...;
chain(parseParameters).\ithen(validateParameters).\ithen(doStuff).\ithen(writeResponse).with(request);
```


## Optional chaining
When you are mixing callables returning optional types (types that can be null), with callables not accepting nulls, you need to explicitly check the existence.
Chaining can help you, checking that partial results are null before being passed to callables.
For doing so, just use the `thenOptionally` method for chaining. This will check the result for the first callable, downcast if not null, and chain to the second callable. If result for first callable is null, then second callable won't even be invoked, and `null` will be returned.

### Optional chaining sample
Following code:
```
value initial = ... ;
value mayBeNull = canProduceNull(initial);
value alsoMayBeNull = if (exists mayBeNull) doNotAcceptNulls(mayBeNull)
```
Can be rewritten as
```
chain(iCanProduceNull).thenOptionally(doNotAcceptNull).with(initial);
```
If `canProduceNull` results in `null`, `doNotAcceptNull` will be skipped.


# Spreading chaining
Basic chaining is good when all callables both accept and return a single result. But many many times callables accept many parameters.
For this situations, Ceylon offer type-safe tuples and spreading.
Ceylon allow a callable accepting several parameters
```
ReturnType func(Type1 param1, Type2 param2, ..., TypeN paramn)
```
to be invoked either by explicitly enumerating parameters
```
Type1 param1 = ...;
Type2 param2 = ...;
...
TypeN paramn = ...;
ReturnType result = func(param1, param2, ..., paramn);
```
Or by having a tuple, and spreading its values:
```
[Type1, Type2, ..., TypeN] tuple = [param1, param2, ..., paramn]
ReturnType result = func(*tuple);
```
Now, realize that tuples can also be the return for a callable:
```
[Type1, Type2, ..., TypeN] tuple = tupleFunc(...);
ReturnType result = func(*tuple);
```
So here we have the standard situation where Chanining Callables can save the day.
By default, a `IChainable` result can not be spread: it requires that the method used to create the `IChainable` have a spreadable return type.
By using the `thenSpreadable` with the right type of callable, the obtained step is not only a `IChainable`, but an `ISpreadable`.
This interface adds `spreadTo` capabilities, that allow to spread the chain result to following chain steps.

### Spreading chaining sample
Following structure:
```
value initial = ...;
value second = doSomething(initial)
value tuple = iReturnATuple(second);
value result = iAcceptManyParameters(*tuple);
```
can be simplified to:
```
chain(doSomething).thenSpreadable(iReturnATuple).spreadTo(iAcceptManyParameters).with(initial);
```
Note that you can not call `spreadTo` if you did not use `thenSpreadable` first!

But... what if you wan to chain several callable that should spread its results?
Keep on reading.

### Repeated spreading

No worries, that's why `spreadToSpreadable` method was created:

```
value initial = ...;
value second = doSomething(initial)
value tuple = iReturnATuple(second);
value secondTuple = iAcceptAndReturnATuple(*second);
value result = iAcceptManyParameters(*secondTuple);
```
is rewritten as
```
chain(doSomething).thenSpreadable(iReturnATuple).spreadToSpreadable(iAcceptAndReturnATuple).spreaTo(iAcceptManyParameters).with(initial);
```


## Extended Chain starts
Wise reader will notice that, if you must use `thenSpreadable` before spreading you can not spread the first chain step!
True! Even more general: `chain`s first step do not have either spreading nor null-checking capabilities.

If you need this capabilities on the first chain step, then you need to use extended chain starts.

- For being able to spread the first step, use the `chainSpreadable` top-level:
```
chainSpreadable(iReturnATuple).spreadTo(iAcceptManyParameters).with(initial);
```
- For null-safety on the first step, use `chainOptional` top-level:
```
chainOptional(iDoNotAcceptNulls).with(iCanBeNull);
```

## Caveats
There are several points of improvement on this code:
- There is a (minimal) memory footprint for using this construct, opposed to a native `|>` operator that is just syntax sugar.
- You actually can not mix both Optional an Spreadable capabilities, so methods returning something like Null|*Type are not supported
(in fact, this notation is not even supported in current Ceylon distribution).

# Enjoy!
Don't hesitate using and distributing this library, and getting back to me to any doubts or issues you may have.

