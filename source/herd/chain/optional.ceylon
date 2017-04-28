shared interface OptedChain<Keep, Handled> satisfies IInvocable<Keep|Handled> {
    shared Chain<Keep|NewReturn> to<NewReturn>(NewReturn(Handled) newFunc)
            => OptChangingStep<NewReturn,Keep,Handled>(this, newFunc);
}

shared interface OptionalChain<Return>
        satisfies IInvocable<Return> {
    shared OptedChain<Keep,Handled> opt<Keep, Handled>(<Keep|Handled>(Return) newFunc)
            => Optional<Return,Handled,Keep>(this, newFunc);
}

class Optional<Return, Handled, Keep>(IInvocable<Return> prev, <Handled|Keep>(Return) func)
        extends ChainStep<Keep|Handled,Return>(prev, func)
        satisfies OptedChain<Keep,Handled> {}

class OptChangingStep<NewReturn, Keep, Handled>(IInvocable<Keep|Handled> prev, NewReturn(Handled) func)
        satisfies Chain<Keep|NewReturn> {
    shared actual NewReturn|Keep do() => let (prevResult = prev.do()) if (is Handled prevResult) then func(prevResult) else prevResult;
}

"Initial optional step"
shared OptedChain<Keep,Handled> opt<Keep, Handled, Arguments>(Arguments arguments, <Keep|Handled>(Arguments) func)
        => object extends ChainStart<Keep|Handled,Arguments>(func, arguments) satisfies OptedChain<Keep,Handled> {};

"Initial optional spreading step"
shared OptedChain<Keep,Handled> opts<Keep, Handled, Arguments>(Arguments arguments, <Keep|Handled>(*Arguments) func)
        given Arguments satisfies Anything[]
        => object extends SpreadingChainStart<Keep|Handled,Arguments>(func, arguments) satisfies OptedChain<Keep,Handled> {};

