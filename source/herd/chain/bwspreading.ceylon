"ISpreadable provide spreading capabilities to chaining callables"
shared interface IBwSpreading<Return, Arguments>
        satisfies IBwInvocable<Return,Arguments>
        & IBwIterable<Return,Arguments>
        & IBwProbable<Return,Arguments>
        given Return satisfies [Anything*] {

    shared default IBwChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(*Return) newFunc)
            => BwSpreadChaining<NewReturn,Arguments,Return>(this, newFunc);

    shared default IBwSpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(*Return) newFunc)
            given NewReturn satisfies [Anything*]
            => BwSpreadSpreading<NewReturn,Arguments,Return>(this, newFunc);
}

shared interface IBwSpreadable<Return, Arguments>
        satisfies IBwInvocable<Return,Arguments> {
    shared default IBwSpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return) newFunc)
            given NewReturn satisfies [Anything*]
            => BwSpreading<NewReturn,Arguments,Return>(this, newFunc);
}

"Basic class implementing ISpreadable.
 This class actually does nothing but being an ISpreadable, because spreading should be done in the results (handled in next chain step).
 So `to` methods actually provide the capability."
class BwSpreading<NewReturn, Arguments, Return>(IBwInvocable<Return,Arguments> prev, NewReturn(Return) func)
        extends BwInvocableChain<NewReturn,Return,Arguments>(prev, func)
        satisfies IBwSpreading<NewReturn,Arguments>
        given NewReturn satisfies Anything[] {}

"SpreadingChainable actually implemente the spreading functionality"
class BwSpreadChaining<NewReturn, Arguments, Return>(IBwInvocable<Return,Arguments> prev, NewReturn(*Return) func)
        extends BwInvocableSpreading<NewReturn,Return,Arguments>(prev, func)
        satisfies IBwChaining<NewReturn,Arguments>
        given Return satisfies [Anything*] {}

"Like SpreadingChainable, but also provides the spreading capability to the next chain step."
class BwSpreadSpreading<NewReturn, Arguments, Return>(IBwInvocable<Return,Arguments> prevSpreadable, NewReturn(*Return) func)
        extends BwInvocableSpreading<NewReturn,Return,Arguments>(prevSpreadable, func)
        satisfies IBwSpreading<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*] {}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IBwSpreading<Return,Arguments> bwspread<Return, Arguments>(Return(Arguments) func)
        given Return satisfies Anything[]
        => object extends BwInvocableStart<Return,Arguments>(func)
        satisfies IBwSpreading<Return,Arguments> {};

shared IBwSpreading<Return,Arguments> bwspreads<Return, Arguments>(Return(*Arguments) func)
        given Return satisfies Anything[]
        given Arguments satisfies Anything[]
        => object extends BwInvocableStartSpreading<Return,Arguments>(func)
        satisfies IBwSpreading<Return,Arguments> {};