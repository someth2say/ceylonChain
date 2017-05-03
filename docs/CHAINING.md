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
    value ch = chain(initialValue);
```

## Chain steps
Once the chain has started, you can chain more functions by using the `to` method.
This method requires the type returned by the previous function (also known as the type returned by the previous chain, or the incomming type)
satisfy the type for the new function parameter(s).
In other words, the following is accepted:
```
    Integer(Integer) method1 = Integer.successor;
    String(Integer) method2 = Integer.string;
    chain(1).to(method1).to(method2)
```
But this is not 
```
    Integer(Integer) method1 = Integer.successor;
    Integer(String) method2 = String.size;
    chain(1).to(method1).to(method2); // ERROR!
```
Because `method2` expects and `String`, but `method1` provides an `Integer`.

## Utility methods
Almost sure, every time you start a chain, you will provide (at least) one method to be applied onto initial values.
So probably you will write something like:
```
    chain(initialValue).to(initialMethod)...
```

An utility method is provided to save you some strokes: `chainTo`
```
    chainTo(initialValue,initialMethod)...
```
  
This chain is equivalent to the `chain(...).to(...)` counterpart, but some people find it clearer.
 Use the one more appealing to you.


## END
And that's all about basic chaining! This is the most basic tool you will use from this library.
[Next chapter](TEEING.md) we will talk about how to introduce functions into a chain, without retaining its value.
