# Teeing:
 An small variation for the [chaining](CHAINING.md) pattern, that uses functions, but ignores its result (if any):
 ```
     value val1 = method1(initialValue);
     method2(val1);
     value val3 = method3(val1);
```

## Chain steps
Using the `tee` method will allow to insert the method into the chain:
```
    chain(initialValue).tee(method2).to(method3);
```
This is pretty useful for side-effects only functions, like logging or `void` operations:
```
    chain(...).to(generateData).tee(logData).to(methodOnData)...
```

###### Gotcha
Currently, `tee` is pretty limited in relation to spreading. You can not spread a tuple to a `tee` nor to the step just before.

## Chain start
Like for [chaining](CHAINING.md), teeing offer two top-level methods for starting a chain: `tee` and `tees`
```
    value ch = tee(initialValue, logMethod).to(method1);
    value ch2 = tees(initialTuple, logMethodWithManyParams).to(method2);
```

## END
If you already understood  [chaining](CHAINING.md), teeing is just a piece of cake.
[Next chapter](SPREADING.md) will introduce advanced spreading concepts.
