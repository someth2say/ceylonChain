# Spreading:
 In previous chapters we saw you can start chains with a single value (like in `chain`) 
 or with multiple values(by providing a Tuple to `chains`).
 
 But many times, the pattern shows the need to use multiple values anyplace in the method chain.
 ```     
    function method3(Type1 t1, Type2 t2, ...) => ...
    ...
    value val1 = method1(initialValue);
    Type1 t1 = method2(val1);
    Type2 t2 = method3(val1);
    value val3 = method4(t1,t2);
 ```
  
 In Ceylon, we have `Tuple` types, 
 we can spread a `Tuple` into a function when all types do match. So if we have a function 
 returning that `Tuple`, we can do the following: 
 ```     
    [Type1, Type2,...] method2(ParamType param) => ... ;
    function method3(Type1 t1, Type2 t2, ...) => ...
    ...
    value val1 = method1(initialValue);
    [Type1, Type2,...] val2 = method2(val1);
    value val3 = method3(*val2);
 ```
 That is the pattern we can emulate with this module.
 
## Chain steps
Before giving you method names, I should point you to one detail:
Util now, all pattern involved just a single method. But this one involves two.
The first one, forced to return a `Tuple`, and the second one, the one the tuple will be spread to.
So this step is then a bit different, and hence the pattern is also.

For "initiating" the spreading pattern, you should use the `spread` method on a chain step:
```
    chainTo(initialValue,method1).spread(method2)...    
```
This indicates the result for `method2` will be spread to the next step. Then, you can add that next step with the `to` method:
```
    chainTo(initialValue,method1).spread(method2).to(method3)...    
```
Keep that in mind: `spread(x).to(y)` spreads the results of `x` to the `y` function.

###### Multiple spreading
What if the second function should also be spread to a third one?
The following won't work:
```
    [Type1, Type2,...] method2(ParamType param) => ... ;
    [Type4, Type5,...] method3(Type1 t1, Type2 t2, ...) => ...
    function method3(Type4 t4, Type5 t5, ...) => ...
    ...
    chainTo(initialValue,method1).spread(method2).to(method3).to(.. //ERROR: `method3` do not accept `Tuple`    
```
No worries. There is an utility method in the spreading chain for this pattern: the `spread` method.
So you can write:
```
    [Type1, Type2,...] method2(ParamType param) => ... ;
    [Type4, Type5,...] method3(Type1 t1, Type2 t2, ...) => ...
    function method3(Type4 t4, Type5 t5, ...) => ...
    ...
    chainTo(initialValue,method1).spread(method2).spread(method3).to(..     
```

## Chain start
There are three flavors for starting a chain, in relation to spreading.
If your initial value should be spread onto your initial function, the `spread` and `spreadTo` top-levels are the droids you are looking for:
```
    [Type1, Type2,...] initialValue = ...
    spread(initialValue).to(initialFunction)...
    // Or, equivalent
    spreadTo(initialValue,initialFunction)...
```

If your initial function returns a `Tuple`, and your second function accepts multiple parameters, you will need
to use the `chainSpread` top-level function (a short form for the `chain(...).spread(..)` pattern):
```
    [Type1, Type2,...] method1(InitialType initialValue) => ... ;
    function method2(Type1 t1, Type2 t2, ...) => ...
    ...
    chainSpread(initialValue,method1).to(method2)...
    // Or, equivalent
    chain(initialValue).spread(method1).to(method2)...
```

## END
Spreading and Tuples are ideas pretty close to Ceylon, and maybe not that affine to other languages.
Luckily Ceylon's type system is strong enough do what is need.
 
[Next chapter](ITERATING.md) will show you how to merge chains with the trending 
topic of `Streams` and `Iterables` (someone said functional programming? :)
