"Chain step that allows you to chaing method invocations, but ignoring its result.
 <pre>
    value val1 = method1(initialValue);
    methodWithoutSignificantResult(val1);
    value val2 = method2(val1);
 </pre>
 That is, provide the ability to chain the results from a the previous steps to next chain steps, ignoring function results.

 Example:
 <pre>
    [[Chain]]<Integer> ch = [[chainF]](1, Integer.successor);
    [[Chain]]<Integer> ch2 = ch.[[tee]]((Integer i) { if (i.negative) {fail();}});
    assertEquals(ch2.[[do]](), 2);
 </pre>

 Note that chaining different steps does not vary the type for chain arguments, as those are defined by the parameters for chain initial step."
shared interface TeeingChain<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by passing the result of the chain so far to a new function.
     The new function MUST accept the return type for the chain so far as its only parameter."
    see (`function package.tee`)
    shared Chain<Return> tee(Anything(Return) newFunc)
            => Teeing<Return>(this, newFunc);
}

class Teeing<PrevReturn>(IInvocable<PrevReturn> prev, Anything(PrevReturn) func)
        satisfies Chain<PrevReturn> {
    shared actual PrevReturn do() {
        value prevResult = prev.do();
        func(prevResult);
        return prevResult;
    }
}

"Initial chaining step, that just execute the function with provided arguments, and then pass arguments by."
shared Chain<Arguments> tee<Arguments>(Arguments arguments, Anything(Arguments) func)
        => object satisfies Chain<Arguments> {
    shared actual Arguments do() {
        func(arguments);
        return arguments;
    }
};

