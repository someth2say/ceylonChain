"ISpreadable provide spreading capabilities to chaining callables"
shared interface ISpreading<Return, Arguments>
        satisfies IInvocable<Return> & IIterable<Return,Arguments> & IProbable<Return,Arguments>
        given Return satisfies [Anything*] {

    shared default IChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(*Return) newFunc)
            => SpreadChaining<NewReturn,Arguments,Return>(this, newFunc);

    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(*Return) newFunc)
            given NewReturn satisfies [Anything*]
            => SpreadSpreading<NewReturn,Arguments,Return>(this, newFunc);
}

shared interface ISpreadable<Return, Arguments>
        satisfies IInvocable<Return> {
    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return) newFunc)
            given NewReturn satisfies [Anything*]
            => Spreading<NewReturn,Arguments,Return>(this, newFunc);
}

"Basic class implementing ISpreadable.
 This class actually does nothing but being an ISpreadable, because spreading should be done in the results (handled in next chain step).
 So `to` methods actually provide the capability."
class Spreading<NewReturn, Arguments, Return>(IInvocable<Return> prev, NewReturn(Return) func)
        extends InvocableChain<NewReturn,Return>(prev, func)
        satisfies ISpreading<NewReturn,Arguments>
        given NewReturn satisfies Anything[] {}

"SpreadingChainable actually implemente the spreading functionality"
class SpreadChaining<NewReturn, Arguments, Return>(IInvocable<Return> prev, NewReturn(*Return) func)
        extends InvocableSpreading<NewReturn,Return>(prev, func)
        satisfies IChaining<NewReturn,Arguments>
        given Return satisfies [Anything*] {}

"Like SpreadingChainable, but also provides the spreading capability to the next chain step."
class SpreadSpreading<NewReturn, Arguments, Return>(IInvocable<Return> prevSpreadable, NewReturn(*Return) func)
        extends InvocableSpreading<NewReturn,Return>(prevSpreadable, func)
        satisfies ISpreading<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*] {}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared ISpreading<Return,Arguments> spread<Return, Arguments>(Return(Arguments) func, Arguments arguments)
        given Return satisfies Anything[]
        => object extends InvocableStart<Return,Arguments>(func, arguments)
        satisfies ISpreading<Return,Arguments> {};

shared ISpreading<Return,Arguments> spreads<Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        given Return satisfies Anything[]
        given Arguments satisfies Anything[]
        => object extends InvocableStartSpreading<Return,Arguments>(func, arguments)
        satisfies ISpreading<Return,Arguments> {};