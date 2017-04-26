"Chain step that provides capabilities to skip null values.
 <pre>
    value nullable = methodThatMayReturnNull(initialValue);
    value nextNullable = if (exists nullable) then methodThatDoesNotAcceptNull(nullable) else null;
    ...
 </pre>

 This step receives a nullable type, and holds a function handling the same non-nullable type.
 If incomming value is accepted by the function, then the function is applied to the incomming value, and its return is
 forwarded to next chain step.
 If incommin value is not accepted by the function (say, it is null), then null is directly forwarded.

 <pre>
    Integer? foo(Integer i) => if (i.even) i else null;
    Integer bar(Integer i) => i.successor;

    [[Chain]]<Integer?,Integer> sp = [[chain]](2,foo)
    [[Chain]]<Integer?,Integer> ch = sp.[[ifExists]](bar);
    assertEquals(sp.[[do]](),3); // foo returns 2, then bar return 3
    assertEquals([[chain]](1,foo).[[ifExists]](bar).[[do]](),null); // foo returns 'null' that is not accepted by bar, so 'null' just is passed by.
 </pre>

 [[NullSafeChain]] is the precursor for [[ProbingChain]].
 As you can see, the behaviour is exactly the same to [[ProbingChain]] for methods returning optional types.
 [[NullSafeChain]] is just provided for simplicity on those cases."
shared interface NullSafeChain<Handled>
        satisfies IInvocable<Handled|Null> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     The incomming type will be nullable (as required for [[NullSafeChain]], but function will not
     necessary accept nulls. If incomming value is not null, then function will be applied, and its result
     returned. If incomming value is null, then null will be returned (function will be skipped).
     "
    see (`function package.ifExists`, `function package.ifExistss`)

    shared Chain<NewReturn|Null> ifExists<NewReturn>(NewReturn(Handled) newFunc)
            => NullTrying<NewReturn,Handled>(this, newFunc);
}

class NullTrying<NewReturn, Handled>(IInvocable<Handled|Null> prev, NewReturn(Handled) func)
        satisfies Chain<NewReturn|Null> {
    shared actual NewReturn? do() => let (prevResult = prev.do()) if (is Handled prevResult) then func(prevResult) else null;
}

shared Chain<Return|Null> ifExists<Return, Handled>(Handled|Null arguments, Return(Handled) func)
        => object satisfies Chain<Return|Null> {
    shared actual Return|Null do() => if (is Handled arguments) then func(arguments) else arguments;
};

shared Chain<Return|Null> ifExistss<Return, Handled>(Handled|Null arguments, Return(*Handled) func)
        given Handled satisfies Anything[]
        => object satisfies Chain<Return|Null> {
    shared actual Return|Null do() => if (is Handled arguments) then func(*arguments) else arguments;
};