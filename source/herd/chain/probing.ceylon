"Chain step that only will invoke the associated function if incomming type is applicable. Else, the incoming type pass by.
 <pre>
    value val1 = method1(initialValue);
    value val2 = if (is Method2ParameterType val1) then method2(val1) else val1;
    ...
 </pre>

 If the incoming type is assignable to this chain step's function, then function is used, and its return value is forwarded.
 If the incomming type is *NOT* assignable, then the incomming value is returned.

 [[ProbingChain]] is the evolution for [[NullSafeChain]], and type non-aserting relative for [[ForcingChain]].

 Example 1: Emulating [[NullSafeChain]]
 If both methods only differ on the `Null` type, [[probe]] behaves exactly like [[NullSafeChain]]
 <pre>
    Integer? foo(Integer i) => if (i.even) i else null;
    Integer bar(Integer i) => i.successor;

    assertEquals([[chain]](2,foo).[[probe]](bar).[[do]](),3); // foo returns 2, then bar return 3
    assertEquals([[chain]](1,foo).[[probe]](bar).[[do]](),null); // foo returns 'null' that is not accepted by bar, so 'null' just is passed by.
 </pre>

 Example 2: Exception handling / Type reduction / Default values
 If you can handle one of the incomming types and transform it to the other one, [[probe]] matches perfectly.
 <pre>
    Integer handleException(ParseException ex) { print(ex.description); return 0; }
    Integer handleInt(Integer i) => i.successor;

    assertEquals([[chain]](\"3\",Integer.parse).[[probe]](handleException).[[probe]](handleInt).[[do]](),4); // parse is succesfull, so handleException does not math, but handleInt does
    assertEquals([[chain]](\"three\",Integer.parse).[[probe]](handleException).[[probe]](handleInt).[[do]](),1) // parse returns an exception, handled by handleException, that prints and returns 0, that is then matched by handleInt
 </pre>

 This is the evolution for [[NullSafeChain]], and type non-aserting relative for [[ForcingChain]].

 Note that [[probe]] chain steps will **not** 'absorb' the actually matched type.
 This mean that the matched type will keep appearing forward in the chain type paramters (in latest sample, `ParseException`).
 Because of that, [[probe]] chain steps can be very tricky in complex cases (i.e. when return types are complex, or many different paths can be taken.
 Use with caution."
shared interface ProbingChain<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    see (`function package.probe`, `function package.probes`)
    shared Chain<NewReturn|Return> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc)
            => Probing<NewReturn,Return,FuncArgs>(this, newFunc);
}

class Probing<NewReturn, Return, FuncArgs>(IInvocable<Return> prev, NewReturn(FuncArgs) func)
        satisfies Chain<NewReturn|Return> {
    "If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    shared actual NewReturn|Return do() => let (prevResult = prev.do()) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

"Initial probing step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Use with caution."
shared Chain<Return|Arguments> probe<Return, FuncArgs, Arguments>(Arguments arguments, Return(FuncArgs) func)
        => object satisfies Chain<Return|Arguments> {
    shared actual Return|Arguments do() => if (is FuncArgs arguments) then func(arguments) else arguments;
};

"Initial probing step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Difference with [[probe]] is that this chain requires arguments to be a tuple, that will try to be spread into current function.
 Use with caution."
shared Chain<Return|Arguments> probes<Return, FuncArgs, Arguments>(Arguments arguments, Return(*FuncArgs) func)
        given FuncArgs satisfies Anything[]
        => object satisfies Chain<Return|Arguments> {
    shared actual Return|Arguments do() => if (is FuncArgs arguments) then func(*arguments) else arguments;
};



