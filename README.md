# Chaining Callables for Ceylon

Just a proof of concept.
The idea is to emulate headfish (`|>`) operator (as described in https://github.com/ceylon/ceylon/issues/6615, but using only standard Ceylon classes, and the strenght of the typechecker.

# Usage
Simple use the `chain` method to start a chained method call, and provide the first function reference.
```
ChainingCallable<Integer,String> stringSizeChain = chain(String.size);
```
This will create a `ChainingCallable` object, that allows to chain other methods in different flavours. Chain more function references by using the provided methods:
- `andThen`: Headfish operator `|>`. Invokes the first function, and then passes its results to the second function.
- `ifExistsThen`: Crying-headfish operator `|?>`. Also forwards the value from the first method to the second, but only if this value is not `null`. If first function returned `null`, then second function is not evaluated, and `null` is returned. 
- `ifSpreadThen`: Dead-headfish opeator `|*>`. It works with methods that accept severals parameters, instead of a single one. Result from first method (should be an iterable) is spread, and sent to the second method as its arguments.
- `with`: This method finalizes the chain, by providing its parameters, and evaluating functions in the right order.

# Samples
- Response handling
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

chain(parseParameters).andThen(validateParameters).andThen(doStuff).andThen(writeResponse).with(request);
```

- More examples to be added.

# Caveats
There are several points of improvement on this code:
- `ifSpreadThen`method is not completelly typesafe, so it can return `null` if the result of the first method is not spreadable.
- There is a (minimal) memory footprint for using this construct, contrary to the `|>`operator that is just syntax sugar.
- Chaining callables starts with 'chain' method (or creating a ChainingCallable). This currently does not allow spreading initial parameters, nor multiple parameters chains.

#Enjoy!
