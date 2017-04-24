"Chain step that provides basic tee capabilities.
 That is, provide the ability to chain the results from a the previous steps to next chain steps, ignoring function results.

 Example:
 <pre>
    ITeeing<Integer,String> bwch = chain(\"10\",Integer.parse)
    ITeeing<Boolean,String> ch = sp.to(Integer.even);
    assertEquals(ch.do(),true);
 </pre>

 Note that chaining different steps does not vary the type for chain arguments, as those are defined by the parameters for chain initial step."
shared interface ITeeable<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by passing the result of the chain so far to a new function.
     The new function MUST accept the return type for the chain so far as its only parameter."
    see (`function package.chain`, `function package.chains`)
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

"Initial chaining step for a chain, that just allow further chain steps to be added."
shared Chain<Arguments> tee<Arguments>(Arguments arguments, Anything(Arguments) func)
        => object satisfies Chain<Arguments> {
    shared actual Arguments do() {
        func(arguments);
        return arguments;
    }
};

"Initial chaining step for a  chain, that just allow further chain steps to be added.
  The only difference with [[tee]] is that [[tees]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared Chain<Arguments> tees<Arguments>(Arguments arguments, Anything(*Arguments) func)
        given Arguments satisfies Anything[]
        => object satisfies Chain<Arguments> {
    shared actual Arguments do() {
        func(*arguments);
        return arguments;
    }
};
