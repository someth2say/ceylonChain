"Backward chain step that provides basic chaining capabilities.
 That is, provide the ability to chain the results from a function to next chain steps.
 Basic chaining is mainly performed with the [[to]] method;

 Example:
 <pre>
    IBwChaining<Integer,String> bwch = bwchain(Integer.parse)
    IBwChaining<Boolean,String> ch = sp.to(Integer.even);
    assertEquals(ch.with(\"10\"),true);
    assertEquals(ch.with(\"1\"),false);
 </pre>

 Note that chaining different steps does not vary the type for chain arguments, as those are defined by the parameters for chain initial step's function.
 "
shared interface IBwChaining<Return, Arguments>
        satisfies IBwInvocable<Return,Arguments>
        & IBwIterable<Return,Arguments>
        & IBwChainable<Return,Arguments>
        & IBwProbable<Return,Arguments>
        & IBwSpreadable<Return,Arguments>
{}

"Aspect or trait interface that provide backward chaining capability. "
shared interface IBwChainable<Return, Arguments>
        satisfies IBwInvocable<Return,Arguments> {
    shared default IBwChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc)
            => BwChaining<NewReturn,Arguments,Return>(this, newFunc);
}

class BwChaining<Return, Arguments, PrevReturn>(IBwInvocable<PrevReturn,Arguments> prev, Return(PrevReturn) func)
        extends BwInvocableChain<Return,PrevReturn,Arguments>(prev, func)
        satisfies IBwChaining<Return,Arguments> {}

"Initial chaining step for a backward chain, that just allow further chain steps to be added."
shared IBwChaining<Return,Arguments> bwchain<Return, Arguments>(Return(Arguments) func)
        => object extends BwInvocableStart<Return,Arguments>(func)
        satisfies IBwChaining<Return,Arguments> {};

"Initial chaining step for a backward chain, that just allow further chain steps to be added.
  The only difference with [[bwchain]] is that [[bwchains]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared IBwChaining<Return,Arguments> bwchains<Return, Arguments>(Return(*Arguments) func)
        given Arguments satisfies Anything[]
        => object extends BwInvocableStartSpreading<Return,Arguments>(func)
        satisfies IBwChaining<Return,Arguments> {};
