"Chain step that provides spreading capabilities.
 That is, provide the ability to spread the returning tuple elements into the next chain step's function parameters.
 Spreading chain steps require a function whose return type can be spreaded (i.o.w, satisfies [Anything*])

 Example:
 <pre>
    [Integer,Boolean] foo(Integer i) => [i,i.even];
    Integer bar(Integer i, Boolean b) => if (b) then i else 0;

    assertEquals(spread(1,foo).to(bar).do(),0); // foo returns [1,false], hence bar returns 0;
    assertEquals(spread(2,foo).to(bar).do(),2); // foo returns [2,true], hence bar returns 2;
 </pre>"
shared interface ISpreading<Return, Arguments>
        satisfies IInvocable<Return> & IIterable<Return,Arguments> & IProbable<Return,Arguments>
        given Return satisfies [Anything*] {

    shared default IChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(*Return) newFunc)
            => SpreadChaining<NewReturn,Arguments,Return>(this, newFunc);

    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(*Return) newFunc)
            given NewReturn satisfies [Anything*]
            => SpreadSpreading<NewReturn,Arguments,Return>(this, newFunc);
}

"Aspect or trait interface that provide spreading capability. "
shared interface ISpreadable<Return, Arguments>
        satisfies IInvocable<Return> {
    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return) newFunc)
            given NewReturn satisfies [Anything*]
            => Spreading<NewReturn,Arguments,Return>(this, newFunc);
}

class Spreading<NewReturn, Arguments, Return>(IInvocable<Return> prev, NewReturn(Return) func)
        extends InvocableChain<NewReturn,Return>(prev, func)
        satisfies ISpreading<NewReturn,Arguments>
        given NewReturn satisfies Anything[] {}

class SpreadChaining<NewReturn, Arguments, Return>(IInvocable<Return> prev, NewReturn(*Return) func)
        extends InvocableSpreading<NewReturn,Return>(prev, func)
        satisfies IChaining<NewReturn,Arguments>
        given Return satisfies [Anything*] {}

class SpreadSpreading<NewReturn, Arguments, Return>(IInvocable<Return> prevSpreadable, NewReturn(*Return) func)
        extends InvocableSpreading<NewReturn,Return>(prevSpreadable, func)
        satisfies ISpreading<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*] {}

"Initial spreading step for a chain, that can spread its results to the following chain step's function. "
shared ISpreading<Return,Arguments> spread<Return, Arguments>(Arguments arguments, Return(Arguments) func)
        given Return satisfies Anything[]
        => object extends InvocableStart<Return,Arguments>(func, arguments)
        satisfies ISpreading<Return,Arguments> {};

"Initial spreading step for a chain, that can spread its results to the following chain step's function.
 The only difference with [[spread]] is that [[spreads]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared ISpreading<Return,Arguments> spreads<Return, Arguments>(Arguments arguments, Return(*Arguments) func)
        given Return satisfies Anything[]
        given Arguments satisfies Anything[]
        => object extends InvocableStartSpreading<Return,Arguments>(func, arguments)
        satisfies ISpreading<Return,Arguments> {};