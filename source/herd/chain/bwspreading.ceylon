"Backward chain step that provides spreading capabilities.
 That is, provide the ability to spread the returning tuple elements into the next chain step's function parameters.
 Spreading chain steps require a function whose return type can be spreaded (i.o.w, satisfies [Anything*])

 Example:
 <pre>
    [Integer,Boolean] foo(Integer i) => [i,i.even];
    Integer bar(Integer i, Boolean b) => if (b) then i else 0;

    IBwSpreading<[Integer,Boolean],Integer> sp = bwspread(foo)
    IBwChaining<Integer,Integer> ch = sp.to(bar);
    assertEquals(ch.with(1),0);
    assertEquals(ch.with(2),2);
 </pre>
 "
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

"Aspect or trait interface that provide backward spreading capability. "
shared interface IBwSpreadable<Return, Arguments>
        satisfies IBwInvocable<Return,Arguments> {
    shared default IBwSpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return) newFunc)
            given NewReturn satisfies [Anything*]
            => BwSpreading<NewReturn,Arguments,Return>(this, newFunc);
}

class BwSpreading<NewReturn, Arguments, Return>(IBwInvocable<Return,Arguments> prev, NewReturn(Return) func)
        extends BwInvocableChain<NewReturn,Return,Arguments>(prev, func)
        satisfies IBwSpreading<NewReturn,Arguments>
        given NewReturn satisfies Anything[] {}

class BwSpreadChaining<NewReturn, Arguments, Return>(IBwInvocable<Return,Arguments> prev, NewReturn(*Return) func)
        extends BwInvocableSpreading<NewReturn,Return,Arguments>(prev, func)
        satisfies IBwChaining<NewReturn,Arguments>
        given Return satisfies [Anything*] {}

class BwSpreadSpreading<NewReturn, Arguments, Return>(IBwInvocable<Return,Arguments> prevSpreadable, NewReturn(*Return) func)
        extends BwInvocableSpreading<NewReturn,Return,Arguments>(prevSpreadable, func)
        satisfies IBwSpreading<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*] {}

"Initial spreading step for a backward chain, that can spread its results to the following chain step's function. "
shared IBwSpreading<Return,Arguments> bwspread<Return, Arguments>(Return(Arguments) func)
        given Return satisfies Anything[]
        => object extends BwInvocableStart<Return,Arguments>(func)
        satisfies IBwSpreading<Return,Arguments> {};

"Initial spreading step for a backward chain, that can spread its results to the following chain step's function.
 The only difference with [[bwspread]] is that [[bwspreads]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared IBwSpreading<Return,Arguments> bwspreads<Return, Arguments>(Return(*Arguments) func)
        given Return satisfies Anything[]
        given Arguments satisfies Anything[]
        => object extends BwInvocableStartSpreading<Return,Arguments>(func)
        satisfies IBwSpreading<Return,Arguments> {};