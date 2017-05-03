# F.A.Q.

###### Previous versions do accept passing the initial parameters **at the end of the chain**. That allowed me to use chains as a 'strategy', and pass non-applied chains
as method references! Why this feature has been removed?

Yes, previously you were able to write chains like this:
```
value ch = chain(...).to(...)...with(initialValue);
```
On one side, this is less readable: initial value is at the end of the chain, instead of the beginning.

But most important, this have been proven to be not type safe, specially with partial chains.
Can you guess the type for the following:
```
value ch = probe(Integer.successor);
```
One may thing it is something like a chain that accepts an `Integer` and returns another `Integer`. But you are wrong.
`probe` detaches the argument type from the function arguments type, in order to perform optional application.
Hence, the type for the previous chain is `Chain<Nothing>` meaning that the compiler known nothing for the chain argument's type.

Not good.

If you need to create method references for chains, you may simply wrap the chain into a function:
  ```
  function myChain(Initial initialValue) => chain(initialValue).to(...)...do();
  value reference = myChain; // reference to the chain
  value val = reference(foo); // Invoking the reference.
  ```

###### Also in previous versions, you can just use a function that do not accepts nulls when incomming type contains nulls, via the `thenOptionally` method. How can I do that now?
You have many alternatives.
- First one, recommended, use the `ifExists` top-level for "Null Safe" patterns. It works the same way than old `thenOptionally`.
- Second, use the `probe` pattern. Getting back to documentation sample code:
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
return chainTo(request, parseParameters).to(validateParameters).probe(doStuff).probe(writeResponse).do()
```
For clarity, we can split chain into steps:
```
Chain<Params> ch1 = chainTo(request, parseParameters);
Chain<Params|Null> ch1.to(validateParameters); // Here appears the null type we want to 'flow'
Chain<Params|Null|Output> ch3 = ch2.probe(doStuff); // Note 'Null' keeps flowing...
Chain<Params|Null|Output|Response> ch4 = ch3.probe(writeResponse); // And not only 'Null', but every type parameter flows...
return ch4.do(); // The actual return type is `Params|Null|Output|Response`
```
- Third one, use the `strip` pattern, to strip-out the `Null` from the rest, and just handle the rest.
```
return chainTo(request, parseParameters).strip<Params,Null>(validateParameters.lTo(doStuff).lTo(writeResponse).do(); 
```
Or, for clarifying types:
```
Chain<Params> ch1 = chainTo(request, parseParameters);
StrippedChain<Params|Null> ch1.strip<Params,Null>(validateParameters); // Here appears the null type we want to 'flow'
StrippedChain<Output|Null> ch3 = ch2.lTo(doStuff); // Note 'Null' keeps flowing, but Params not 
StrippedChain<Response|Null> ch4 = ch3.lTo(writeResponse); 
return ch4.do(); // The actual return type is `Response|Null`.. not bad, isn't it?
```

You choose.

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
    Options options = chain(process.arguments)
        .to(commandLineOptions)
        .tee(compileModule).do();
    
    Integer exitCode = spread([options.moduleName, options.moduleVersion],loadModule)
        .tee(exitOnNullModule)
        .strip<GoalDefinitionsBuilder,[InvalidGoalDeclaration+]>(readAnnotations)
        .lrTo(startGdb(options),reportInvalid)
        .do();
        
    process.exit(exitCode);
}

Integer startGdb(Options options)(GoalDefinitionsBuilder gdb) => start(gdb, consoleWriter, options.runtime, [*options.goals]);

Integer reportInvalid([InvalidGoalDeclaration+] gdb) {
   reportInvalidDeclarations(goals, consoleWriter);
   return 1;
}

void exitOnNullModule(Options options)(Module? mod){
    if (!exists mod) {
        process.writeErrorLine("Module '``options.moduleName``/``options.moduleVersion``' not found");
        process.exit(1);
    }
}
```
Many more examples will come.
