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
Hence, the type for the previous chain is `IForcing<Integer,Nothing>` meaning that the return type is known to be `Integer`, but compiler
known nothing for the chain argument's type.

If you need to create method references for chains, you may simply wrap the chain into a function:
  ```
  function myChain(Initial initialValue) => chain(initialValue).to(...)...do();
  value reference = myChain; // reference to the chain
  value val = reference(foo); // Invoking the reference.
  ```

###### Also in previous versions, you can just use a function that do not accepts nulls when incomming type contains nulls, via the `thenOptionally` method. How can I do that now?
`probing` chain steps is what you need.
`probing` accept any incomming type, and remember `Null` is just another type (and `Type?` is just an alias for `Type|Null`).

Getting back to documentation sample code:
```
Request request = ...;
Params params = parseParameters(request);
Params? validParams = validateParameters(params);
Output output = doStuff(validParams); // Error, doStuff accepts Params, not Params?
Result result = writeResponse(output);
return result;
```
When using chains, it is translated to:
```
return chain(request, parseParameters).to(validateParameters).probe(doStuff).probe(writeResponse).do()
```
For clarity, we can split chain into steps:
```
IChaining<Params> ch1 = chain(request, parseParameters);
IChaining<Params|Null> ch1.to(validateParameters); // Here appears the null type we want to 'flow'
IProbing<Params|Null|Output> ch3 = ch2.probe(doStuff); // Note 'Null' keeps flowing...
IProbing<Params|Null|Output|Response> ch4 = ch3.probe(writeResponse); // And not only 'Null', but every type parameter flows...
return ch4.to(); // The actual return type is `Params|Null|Output|Response`
```


###### So good, so far. But can I see real life examples where this library can be used?
Sure! Here are some:

**From Gyokuro Spring demo:**
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


**From `ceylon.build`**
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
    chains([options.moduleName, options.moduleVersion],loadModule)      // IChaining<Null|Module>,
        .to(handleNullModule(options))                                  // IChaining<Module|Integer>
        .probe(readAnnotations)                                         // IProbing<Module|Integer|GoalDefinitionsBuilder|[InvalidGoalDeclaration+]>
            .probe(startGdb(options))                                   // IProbing<Module|Integer|GoalDefinitionsBuilder|[InvalidGoalDeclaration+]>
            .probe(reportInvalid)                                       // IProbing<Module|Integer|GoalDefinitionsBuilder|[InvalidGoalDeclaration+]>
        .probe(process.exit)                                            // IProbing<Module|Integer|GoalDefinitionsBuilder|[InvalidGoalDeclaration+]>
        .do();                                                          // If execution actually leaves the chain, something really gone wrong.
}

Integer startGdb(Options options)(GoalDefinitionsBuilder gdb) => start(gdb, consoleWriter, options.runtime, [*options.goals]);

Integer reportInvalid([InvalidGoalDeclaration+] gdb) {
   reportInvalidDeclarations(goals, consoleWriter);
   return 1;
}

Integer|Module handleNullModule(Options options)(Module? mod){
    if (exists mod) {
        return mod;
    } else {
        process.writeErrorLine("Module '``options.moduleName``/``options.moduleVersion``' not found");
        return 1;
    }
}
```
An alternative approach may be eliminating all `Integer` return types, and directly invoke `process.exit`... but this way is more educational :)
```
shared void run() {
    Options options = commandLineOptions(process.arguments);
    compileModule(options);
    chains([options.moduleName, options.moduleVersion],loadModule)      // IChaining<Null|Module>,
        .to(handleNullModule(options))                                  // IChaining<Module>
        .to(readAnnotations)                                            // IChaining<GoalDefinitionsBuilder|[InvalidGoalDeclaration+]>
            .probe(startGdb(options))                                   // IProbing<GoalDefinitionsBuilder|[InvalidGoalDeclaration+]>
            .probe(reportInvalid)                                       // IProbing<GoalDefinitionsBuilder|[InvalidGoalDeclaration+]>
        .do();                                                          // If execution actually leaves the chain, something really gone wrong.
}

Module handleNullModule(Options options)(Module? mod){
    if (!exists mod) {
        process.writeErrorLine("Module '``options.moduleName``/``options.moduleVersion``' not found");
        return process.exit(1);
    }
    return mod;
}

Nothing startGdb(Options options)(GoalDefinitionsBuilder gdb) => chain([gdb, consoleWriter, options.runtime, [*options.goals]],start).to(process.exit).do();

Nothing reportInvalid([InvalidGoalDeclaration+] gdb) {
   reportInvalidDeclarations(goals, consoleWriter);
   return process.exit(1);
}
```

Even, if you feel adventurous, you can opt for the `force` chain step:
```
shared void run() {
    Options options = commandLineOptions(process.arguments);
    compileModule(options);
    chains([options.moduleName, options.moduleVersion],loadModule)      // IChaining<Null|Module>,
        .force(handleNullModule(options))                               // IForcing<Module>
        .to(readAnnotations)                                            // IChaining<GoalDefinitionsBuilder|[InvalidGoalDeclaration+]>
            .force(startGdb(options))                                   // IForcing<[InvalidGoalDeclaration+]>
            .to(reportInvalid)                                          // IProbing<Nothing>
        .do();
}

Module handleNullModule(Options options)(Null mod){
    process.writeErrorLine("Module '``options.moduleName``/``options.moduleVersion``' not found");
    return process.exit(1);
}

[InvalidGoalDeclaration+] startGdb(Options options)(GoalDefinitionsBuilder gdb) => chain([gdb, consoleWriter, options.runtime, [*options.goals]],start).to(process.exit).do();

Nothing reportInvalid([InvalidGoalDeclaration+] gdb) {
   reportInvalidDeclarations(goals, consoleWriter);
   return process.exit(1);
}
```

Many more examples will come.
