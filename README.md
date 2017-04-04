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

Some languages offer fishead (`|>`) operator, allowing chaining `methods`, in a fashion that the result for the first one is used as parameter for the second one.
This library offer emulating this operator (as described in https://github.com/ceylon/ceylon/issues/6615, but using only standard Ceylon classes, and the strength of the typechecker.

Sources for Chaining Callables can be found at https://github.com/someth2say/ceylonChain

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
As seen, chaining functions is really straightforward by using this module.
But wise reader can see that this seems only work for simplest cases, where method parameters and results do match, and nothing else is done.
In order to offer wider range of situations where this library can be useful, many other chaining flavors are provided:

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
 Those, when applied onto a `iterate` chain step will provide a new simple chain step, whose return type will be the same than the original method.

:warning:
 The `spread` method of `Iterable` clashes with the `spread` method for spreading the values of a chain step over the next step.
For avoiding this, `spread` method of `iterate` chain steps have been renamed to `spreadIterable`.

### Nullable types and probe
Another use case is when used functions can return 'null', and it should be handled.
Let's say `validateParameters` return `null` if parameters are not valid:
```
Request request = ...;
Params params = parseParameters(request);
Params? validParams = validateParameters(params);
value output = doStuff(validParams); // Error, doStuff accepts Params, not Params?
Result result = writeResponse(output);
return result;
```
But `doStuff` do only accept `Params`, not `Params?`!

Probing chains come to save the day.
By using the `probe` method, `validParams` will be passed to `doStuff` **only** if they are not `null`. Else, the chain step result will just be the same `null`.
Consequently, the result of this probing chain step may be both 'null', or the result of applying the 'validateParameters' function:
```
return chain(request, parseParameters).to(validateParameters).probe(doStuff).probe(writeResponse).do()
```
You may have noticed that `probe` is not only used with `doStuff`, but also with `writeResponse`. Why?
Easy: the moment you use `probe`, the non-accepted `null` can just pass by to next chain steps. And `writeResponse` do not accept `null`! Hence, `probe` is needed.
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

## Caveats
There are several points of improvement on this code:
- There is a (minimal) memory footprint for using this construct, opposed to a native `|>` operator that is just syntax sugar.
- As already said, `probe` steps do not actually remove the type when matched.


# F.A.Q.

###### Previous versions do accept passing the initial parameters **at the end of the chain**. That allowed me to use chains as a 'strategy', and pass non-applied chains
as method references! Why this feature has been removed?

Yes, previously you were able to write chains like this:
```
value ch = chain(...).to(...);
...
value = ch.with(initialValue);
```
On one side, this is less readable: initial value is at the end of the chain, instead of the beginning.
But most important, this have been proven to be not type safe, specially with probing chains.
Can you guess the type for the following:
```
value ch = probe(Integer.successor);
```
One may thing it is something like a chain that accepts an `Integer` and returns another `Integer`. But you are wrong.
`probe` detaches the chain argument type from the initial function arguments type, in order to perform optional application.
Hence, the type for the previous chain is `IProbing<Integer,Nothing>` meaning that the return type is known to be `Integer`, but compiler
known nothing for the chain argument's type.

If you need to create method references for chains, you may simply wrap the chain into a function:
  ```
  function myChain(Initial initialValue) => chain(initialValue).to(...)...do();
  value reference = myChain; // reference to the chain
  value val = reference(foo); // Invoking the reference.
  ```

###### So good, so far. But can I see real life examples where this library can be used?
Sure! Here are some:
From Gyokuro Spring demo:
```
shared void run() {
    addLogWriter(writeSimpleLog);
    defaultPriority = trace;

    print("Scanning current package for Spring-annotated classes");
    value springContext = AnnotationConfigApplicationContext(`package`.qualifiedName);

    print("Starting gyokuro application");

    value controllerAnnotation = javaAnnotationClass<ControllerAnnotation>();
    value controllers = [*springContext.getBeansWithAnnotation(controllerAnnotation).values()];

    Application {
        // We provide our own controller instances instead of letting gyokuro scan a package
        controllers = bind(controllers);
    }.run();
}
```
Can be rewritten as:
```
shared void run() {
    addLogWriter(writeSimpleLog);
    defaultPriority = trace;
    value controllerAnnotation = javaAnnotationClass<ControllerAnnotation>();

    print("Scanning current package for Spring-annotated classes");

    value controllers = chain(`package`.qualifiedName, AnnotationConfigApplicationContext)
        .to(AnnotationConfigApplicationContext.getBeansWithAnnotation(controllerAnnotation))
        .to(JMap.values).do();

    print("Starting gyokuro application");

     Application {
        // We provide our own controller instances instead of letting gyokuro scan a package
        controllers = bind(controllers);
    }.run();
}

```


From `ceylon.build`:
```
shared void run() {
    value writer = consoleWriter;
    Options options = commandLineOptions(process.arguments);
    compileModule(options);
    Module? mod = loadModule(options.moduleName, options.moduleVersion);
    if (exists mod) {
        GoalDefinitionsBuilder|[InvalidGoalDeclaration+] goals = readAnnotations(mod);
        Integer exitCode;
        switch (goals)
        case (is GoalDefinitionsBuilder) {
            exitCode = start(goals, writer, options.runtime, [*options.goals]);
        } case (is [InvalidGoalDeclaration+]) {
            reportInvalidDeclarations(goals, writer);
            exitCode = 1;
        }
        process.exit(exitCode);
    } else {
        process.writeErrorLine("Module '``options.moduleName``/``options.moduleVersion``' not found");
        process.exit(1);
    }
}
```
Goes to
```
shared void run() {
    Options options = commandLineOptions(process.arguments);
    compileModule(options);
    value exitCode = chains([options.moduleName, options.moduleVersion],loadModule) // Produces Module?
        .handle(handleNullModule)                                                   // Produces Integer|Module
        .handle(readModuleAnnotations)                                              // Produces Integer|GoalDefinitionsBuilder|[InvalidGoalDeclaration+]
            .handle(startGdb(options))                                              // Produces Integer|[InvalidGoalDeclaration+]
            .handle(reportInvalid)                                                  // Produces Integer
        .do();
    process.exit(exitCode);
}

Integer|GoalDefinitionsBuilder|[InvalidGoalDeclaration+] readModuleAnnotations(Module mod) => readAnnotations(mod);
Integer|[InvalidGoalDeclaration+] startGdb(GoalDefinitionsBuilder gdb)(Options options) => start(gdb, consoleWriter, options.runtime, [*options.goals]);

Integer reportInvalid([InvalidGoalDeclaration+] gdb) {
   reportInvalidDeclarations(goals, consoleWriter);
   return 1;
}

Integer|Module handleNullModule(Null null){
    process.writeErrorLine("Module '``options.moduleName``/``options.moduleVersion``' not found");
    return 1;
}
```

Many more examples will come.

# Enjoy!
Don't hesitate using and distributing this library, and getting back to me to any doubts or issues you may have.

