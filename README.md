# ceylonChain

Just a proof of concept.
The idea is to emulate `|>` operator (as described in https://github.com/ceylon/ceylon/issues/6615, but using only standard Ceylon classes, and the strenght of the typechecker.

# Usage
Simple use the `chain` method to start a chained method call.
This will create a `ChainingCallable` object, that allows to chain other methods in different flavours:
- `andThen` just forwards the value from the first method to the second.
- `ifExistsThen` does the same, but first check for the existence for the value returned by the first method. If it does not exist, the second method is not even called, and returs `null`.
- `ifSpreadThen` works with methods that accept severals parameters, instead of a single one. Result from first method (should be an iterable) is spread, and sent to the second method as its arguments.

# Caveats
There are several points of improvement on this code:
- `ifSpreadThen`method is not completelly typesafe, so it can return `null` if the result of the first method is not spreadable.
- There is a (minimal) memory footprint for using this construct, contrary to the `|>`operator that is just syntax sugar.
- ChainedCallable starts with the 'chain' method. This currently does not allow spreading, nor multiple parameters.

#Enjoy!
