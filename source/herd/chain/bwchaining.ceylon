"Chaining Callable is like a Callable, but adding method chaining functionality.
 IChainable offers basic method for chaining callables"
shared interface IBwChaining<Return, Arguments>
        satisfies IBwInvocable<Return,Arguments>
        & IBwIterable<Return,Arguments>
        & IBwChainable<Return,Arguments>
        & IBwProbable<Return,Arguments>
        & IBwSpreadable<Return,Arguments>
{}

shared interface IBwChainable<Return, Arguments>
        satisfies IBwInvocable<Return,Arguments> {
    shared default IBwChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc)
            => BwChaining<NewReturn,Arguments,Return>(this, newFunc);
}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class BwChaining<Return, Arguments, PrevReturn>(IBwInvocable<PrevReturn,Arguments> prev, Return(PrevReturn) func)
        extends BwInvocableChain<Return,PrevReturn,Arguments>(prev, func)
        satisfies IBwChaining<Return,Arguments> {}

"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IBwChaining<Return,Arguments> bwchain<Return, Arguments>(Return(Arguments) func)
        => object extends BwInvocableStart<Return,Arguments>(func)
        satisfies IBwChaining<Return,Arguments> {};

"Initial step for a Chaining Spreading Callable. Allow to chain with next step, but adding no extra capabilities"
shared IBwChaining<Return,Arguments> bwchains<Return, Arguments>(Return(*Arguments) func)
        given Arguments satisfies Anything[]
        => object extends BwInvocableStartSpreading<Return,Arguments>(func)
        satisfies IBwChaining<Return,Arguments> {};
