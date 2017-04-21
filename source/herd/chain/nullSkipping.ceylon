"Chain step that provides capabilities to forward Nulls.
 This step receives a nullable type, and holds a function handling the same non-nullable type.
 If incomming value is accepted by the function, then the function is applied to the incomming value, and its return is
 forwarded to next chain step.
 If incommin value is not accepted by the function (say, it is null), then null is directly forwarded.

 <pre>
    Integer? foo(Integer i) => if (i.even) i else null;
    Integer bar(Integer i) => i.successor;

    IChaining<Integer?,Integer> sp = chain(2,foo)
    INullSkipping<Integer?,Integer> ch = sp.nullSkip(bar);
    assertEquals(sp.do(),3); // foo returns 2, then bar return 3
    assertEquals(chain(1,foo).probe(bar).do(),null); // foo returns 'null' that is not accepted by bar, so 'null' just is passed by.
 </pre>

 As you can see, the behaviour is exactly the same to [[IProbing]] for methods returning optional types.
 [[INullTrying]] is just provided for simplicity on those cases.
 "
shared interface INullTrying<Return> satisfies DefaultChain<Return> {}

"Aspect or trait interface that provide null skipping capability."
shared interface INullTryable<Handled>
        satisfies IInvocable<Handled|Null> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     The incomming type will be nullable (as required for [[INullTryable]], but function will not
     necessary accept nulls. If incomming value is not null, then function will be applied, and its result
     returned. If incomming value is null, then null will be returned (function will be skipped).
     "
    see (`function package.nullTry`, `function package.nullTrys`)

    shared INullTrying<NewReturn|Null> nullTry<NewReturn>(NewReturn(Handled) newFunc)
            => NullTrying<NewReturn,Handled>(this, newFunc);
}

class NullTrying<NewReturn, Handled>(IInvocable<Handled|Null> prev, NewReturn(Handled) func)
        satisfies INullTrying<NewReturn|Null> {
    shared actual NewReturn? do() => let (prevResult = prev.do()) if (is Handled prevResult) then func(prevResult) else null;
}

shared INullTrying<Return|Null> nullTry<Return, Handled>(Handled|Null arguments, Return(Handled) func)
        => object satisfies INullTrying<Return|Null> {
    shared actual Return|Null do() => if (is Handled arguments) then func(arguments) else arguments;
};

shared INullTrying<Return|Null> nullTrys<Return, Handled>(Handled|Null arguments, Return(*Handled) func)
        given Handled satisfies Anything[]
        => object satisfies INullTrying<Return|Null> {
    shared actual Return|Null do() => if (is Handled arguments) then func(*arguments) else arguments;
};