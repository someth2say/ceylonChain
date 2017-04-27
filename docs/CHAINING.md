# Chaining:
 The most basic picopattern is the fishead operator: chaining the result for a function to another function.
 ```
     value val1 = method1(initialValue);
     value val2 = method2(val1);
     value val3 = method3(val2);
```

## Chain start
If you already read the [readme](../README.md) page, you probably already known how to start a chain. 
The `chain` top-level method does it for you:
```
    value ch = chain(initialValue, method1);
```
This top-level method creates the chain. In fact, it creates the first step for the chain, the only one accepting the initial value.

But... what if the initial method requires many parameters?
```
    function method1(Type1 t1, Type2 t2...) => ...
```
Then, you need to use the `chains` top-level method (note the `s` at the end, meaning `spreading`).
 
This method requires the initial value to be "spreadable" (IOW, to be a `Tuple`), and also requires that its types actually match
the parameters for the initial method. Then, the initial value tuple will be "spread" into the initial function:

```
    function method1(Type1 t1, Type2 t2,...) => ...
    [Type1,Type2,...] initialValue = ...
    value ch = chains(initialValue,method1);
```

## Chain steps
Once the chain has started, you can chain more functions by using the `to` method.
This method requires the type returned by the previous function (also known as the type returned by the previous chain, or the incomming type)
satisfy the type for the new function parameter(s).
In other words, the following is accepted:
```
    Integer(Integer) method1 = Integer.successor;
    String(Integer) method2 = Integer.string;
    chain(1,method1).to(method2)
```
But this is not 
```
    Integer(Integer) method1 = Integer.successor;
    Integer(String) method2 = String.size;
    chain(1,method1).to(method2); // ERROR!
```
Because `method2` expects and `String`, but `method1` provides an `Integer`.

## END
And that's all about basic chaining! This is the most basic tool you will use from this library.
[Next chapter](TEEING.md) we will talk about how to introduce functions into a chain, without retaining its value.
