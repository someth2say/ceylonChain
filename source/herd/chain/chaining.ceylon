"Chaining Callable is like a Callable, but adding method chaining functionality.
 IChainable offers basic method for chaining callables"
shared interface IChaining<Return, Arguments>
        satisfies IInvocable<Return>
        & IIterable<Return,Arguments>
        & IChainable<Return,Arguments>
        & IProbable<Return,Arguments>
        & ISpreadable<Return,Arguments> {}

shared interface IChainable<Return, Arguments>
        satisfies IInvocable<Return> {
    shared default IChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc)
            => Chaining<NewReturn,Arguments,Return>(this, newFunc);
}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class Chaining<Return, Arguments, PrevReturn>(IInvocable<PrevReturn> prev, Return(PrevReturn) func)
        extends InvocableChain<Return,PrevReturn>(prev, func)
        satisfies IChaining<Return,Arguments> {}

"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IChaining<Return,Arguments> chain<Return, Arguments>(Return(Arguments) func, Arguments arguments)
        => object extends InvocableStart<Return,Arguments>(func, arguments)
        satisfies IChaining<Return,Arguments> {};

"Initial step for a Chaining Spreading Callable. Allow to chain with next step, but adding no extra capabilities"
shared IChaining<Return,Arguments> chains<Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        given Arguments satisfies Anything[]
        => object extends InvocableStartSpreading<Return,Arguments>(func, arguments)
        satisfies IChaining<Return,Arguments> {};
