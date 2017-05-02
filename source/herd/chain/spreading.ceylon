"Chain step that provides spreading capabilities.
 That is, provide the ability to spread the returning tuple elements into the next chain step's function parameters.
 [[SpreadableChain]] steps require a function whose return type can be spreaded (i.o.w, satisfies [Anything*])

 This is a two-step chain. That means, spreading occurs not when chain step is build,
 but when chain step is chained to the following step (via [[to]] or [[spread]] methods).

 Example:
 <pre>
    [Integer,Boolean] foo(Integer i) => [i,i.even];
    Integer bar(Integer i, Boolean b) => if (b) then i else 0;

    assertEquals([[spread]](1,foo).[[to]](bar).[[do]](),0); // foo returns [1,false], hence bar returns 0;
    assertEquals([[spread]](2,foo).[[to]](bar).[[do]](),2); // foo returns [2,true], hence bar returns 2;
 </pre>"
shared interface SpreadableChain<Return> satisfies
          IInvocable<Return>
        given Return satisfies [Anything*] {

    "Adds a new step to the chain, by spreading the result of the chain so far to a new function.
     Chain so far MUST be spreadable (i.o.w should satisfy ISpreadable interface).
     The new function MUST accept an spreadable type (i.o.w a Tuple)."
    see (`interface SpreadingChain`, `function package.spread`, `function package.spreads`)
    shared Chain<NewReturn> to<NewReturn>(NewReturn(*Return) newFunc)
            => SpreadChaining<NewReturn,Return>(this, newFunc);

    "Adds a new step to the chain, by spreading the result of the chain so far to a new function.
     Chain so far MUST be spreadable (i.o.w should satisfy ISpreadable interface), and so will be the new chain.
     The new function MUST BOTH accept return an spreadable type (i.o.w a Tuple)."
    see (`interface SpreadingChain`, `function package.spread`, `function package.spreads`)
    shared SpreadableChain<NewReturn> spread<NewReturn>(NewReturn(*Return) newFunc)
            given NewReturn satisfies [Anything*]
            => SpreadSpreading<NewReturn,Return>(this, newFunc);
}

"Aspect or trait interface that provide spreading capability. "
shared interface SpreadingChain<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     Function MUST return an spreadable type (i.o.w. a Tuple).
     The resulting chain's result MAY be spread into further chain steps."
    shared SpreadableChain<NewReturn> spread<NewReturn>(NewReturn(Return) newFunc)
            given NewReturn satisfies [Anything*]
            => Spreading<NewReturn,Return>(this, newFunc);
}

class Spreading<NewReturn, Return>(IInvocable<Return> prev, NewReturn(Return) func)
        extends ChainStep<NewReturn,Return>(prev, func)
        satisfies SpreadableChain<NewReturn>
        given NewReturn satisfies Anything[] {}

class SpreadChaining<NewReturn, Return>(IInvocable<Return> prev, NewReturn(*Return) func)
        extends SpreadingChainStep<NewReturn,Return>(prev, func)
        satisfies Chain<NewReturn>
        given Return satisfies [Anything*] {}

class SpreadSpreading<NewReturn, Return>(IInvocable<Return> prevSpreadable, NewReturn(*Return) func)
        extends SpreadingChainStep<NewReturn,Return>(prevSpreadable, func)
        satisfies SpreadableChain<NewReturn>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*] {}

"Initial spreading step for a chain, that can spread its results to the following chain step's function. "
shared SpreadableChain<Return> spread<Return, Arguments>(Arguments arguments, Return(Arguments) func)
        given Return satisfies Anything[]
        => object extends ChainStart<Return,Arguments>(func, arguments)
        satisfies SpreadableChain<Return> {};

"Initial spreading step for a chain, that can spread its results to the following chain step's function.
 The only difference with [[spread]] is that [[spreads]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared SpreadableChain<Return> spreads<Return, Arguments>(Arguments arguments, Return(*Arguments) func)
        given Return satisfies Anything[]
        given Arguments satisfies Anything[]
        => object extends SpreadingChainStart<Return,Arguments>(func, arguments)
        satisfies SpreadableChain<Return> {};


