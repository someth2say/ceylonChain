"Chain step that provides spreading capabilities.
 That is, provide the ability to spread the returning tuple elements into the next chain step's function parameters.
 [[SpreadChain]] steps require a function whose return type can be spreaded (i.o.w, satisfies [Anything*])

 This is a two-step chain. That means, spreading occurs not when chain step is build,
 but when chain step is chained to the following step (via [[to]] or [[spread]] methods).

 Example:
 <pre>
    [Integer,Boolean] foo(Integer i) => [i,i.even];
    Integer bar(Integer i, Boolean b) => if (b) then i else 0;

    assertEquals([[spread]](1,foo).[[to]](bar).[[do]](),0); // foo returns [1,false], hence bar returns 0;
    assertEquals([[spread]](2,foo).[[to]](bar).[[do]](),2); // foo returns [2,true], hence bar returns 2;
 </pre>"
shared interface SpreadChain<Return> satisfies Invocable<Return>
        given Return satisfies [Anything*] {

    "Adds a new step to the chain, by spreading the result of the chain so far to a new function.
     Chain so far MUST be spreadable (i.o.w should satisfy ISpreadable interface).
     The new function MUST accept an spreadable type (i.o.w a Tuple)."
    see (`interface SpreadingChain`, `function package.chainSpread`, `function package.spread`)
    shared Chain<NewReturn> to<NewReturn>(NewReturn(*Return) newFunc)
            => SpreadChaining<NewReturn,Return>(this, newFunc);

    "Adds a new step to the chain, by spreading the result of the chain so far to a new function.
     Chain so far MUST be spreadable (i.o.w should satisfy ISpreadable interface), and so will be the new chain.
     The new function MUST BOTH accept return an spreadable type (i.o.w a Tuple)."
    see (`interface SpreadingChain`, `function package.chainSpread`, `function package.spread`)
    shared SpreadChain<NewReturn> spread<NewReturn>(NewReturn(*Return) newFunc)
            given NewReturn satisfies [Anything*]
            => SpreadSpreading<NewReturn,Return>(this, newFunc);
}

"Aspect or trait interface that provide spreading capability. "
shared interface SpreadingChain<Return>
        satisfies Invocable<Return> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     Function MUST return an spreadable type (i.o.w. a Tuple).
     The resulting chain's result MAY be spread into further chain steps."
    shared SpreadChain<NewReturn> spread<NewReturn>(NewReturn(Return) newFunc)
            given NewReturn satisfies [Anything*]
            => Spreading<NewReturn,Return>(this, newFunc);
}

class Spreading<NewReturn, Return>(Invocable<Return> prev, NewReturn(Return) func)
        extends ChainingInvocable<NewReturn,Return>(prev, func)
        satisfies SpreadChain<NewReturn>
        given NewReturn satisfies Anything[] {}

class SpreadChaining<NewReturn, Return>(Invocable<Return> prev, NewReturn(*Return) func)
        extends SpreadingChainStep<NewReturn,Return>(prev, func)
        satisfies Chain<NewReturn>
        given Return satisfies [Anything*] {}

class SpreadSpreading<NewReturn, Return>(Invocable<Return> prevSpreadable, NewReturn(*Return) func)
        extends SpreadingChainStep<NewReturn,Return>(prevSpreadable, func)
        satisfies SpreadChain<NewReturn>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*] {}

abstract class SpreadingChainStep<out Return, PrevReturn>(Invocable<PrevReturn> prev, Return(*PrevReturn) func)
        satisfies Invocable<Return>
        given PrevReturn satisfies Anything[] {
    shared actual Return do() => let (prevResult = prev.do()) func(*prevResult);
}


"Initial spreading step for a chain, that can spread its results to the following chain step's function. "
shared SpreadChain<Arguments> spread<Arguments>(Arguments arguments)
        given Arguments satisfies Anything[]
        => object extends IdentityInvocable<Arguments>(arguments) satisfies SpreadChain<Arguments> {};

"Initial step for a chain, that spreads the first function directly.
 It is just a shortcut for `[[chain]](arguments).[[spread]](func)`"
shared SpreadChain<Return> chainSpread<Return, Arguments>(Arguments arguments, Return(Arguments) func)
        given Return satisfies Anything[]
        => object extends FunctionInvocable<Return,Arguments>(arguments, func)
        satisfies SpreadChain<Return> {};

"Initial spreading step for a chain, that chains the first function directly.
 It is just a shortcut for `[[spread]](arguments).to(func)`"
shared Chain<Return> spreadTo<Return, Arguments>(Arguments arguments, Return(*Arguments) func)
        given Arguments satisfies Anything[]
        => object satisfies Chain<Return> {
    shared actual Return do() => func(*arguments);
};
