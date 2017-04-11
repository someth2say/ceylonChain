"Chain step that provides basic chaining capabilities.
 That is, provide the ability to chain the results from a function to next chain steps.
 Basic chaining is mainly performed with the [[to]] method;

 Example:
 <pre>
    IChaining<Integer,String> bwch = chain(\"10\",Integer.parse)
    IChaining<Boolean,String> ch = sp.to(Integer.even);
    assertEquals(ch.do(),true);
 </pre>

 Note that chaining different steps does not vary the type for chain arguments, as those are defined by the parameters for chain initial step."

shared interface IChaining<Return>
        satisfies IInvocable<Return>
        & IIterable<Return>
        & IChainable<Return>
        & IProbable<Return>
        & ISpreadable<Return>
        & IForzable<Return>
        & ITeeable<Return>
{}

"Aspect or trait interface that provide chaining capability. "
shared interface IChainable<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by passing the result of the chain so far to a new function.
     The new function MUST accept the return type for the chain so far as its only parameter."
    see( `function package.chain`, `function package.chains`)
    shared default IChaining<NewReturn> to<NewReturn>(NewReturn(Return) newFunc)
            => Chaining<NewReturn,Return>(this, newFunc);
}

class Chaining<Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(PrevReturn) func)
        extends InvocableChain<Return,PrevReturn>(prev, func)
        satisfies IChaining<Return> {}

"Initial chaining step for a chain, that just allow further chain steps to be added."
shared IChaining<Return> chain<Return, Arguments>(Arguments arguments, Return(Arguments) func)
        => object extends InvocableStart<Return,Arguments>(func, arguments)
        satisfies IChaining<Return> {};

"Initial chaining step for a  chain, that just allow further chain steps to be added.
  The only difference with [[chain]] is that [[chains]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared IChaining<Return> chains<Return, Arguments>(Arguments arguments, Return(*Arguments) func)
        given Arguments satisfies Anything[]
        => object extends InvocableStartSpreading<Return,Arguments>(func, arguments)
        satisfies IChaining<Return> {};
