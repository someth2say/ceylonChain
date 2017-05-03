shared interface StrippedChain<Left, Right> satisfies Chain<Left|Right> {
    shared StrippedChain<Left,NewRight> rTo<NewRight>(NewRight(Right) newFunc)
            => RightStep<NewRight,Left,Right>(this, newFunc);

    shared StrippedChain<NewLeft,Right> lTo<NewLeft>(NewLeft(Left) newFunc)
            => LeftStep<NewLeft,Left,Right>(this, newFunc);

    shared StrippedChain<NewLeft,NewRight> lrTo<NewLeft, NewRight>(NewLeft(Left) newLFunc, NewRight(Right) newRFunc)
            => LRStep<NewLeft,NewRight,Left,Right>(this, newLFunc, newRFunc);
}

shared interface StrippingChain<Return>
        satisfies Invocable<Return> {

    shared StrippedChain<Left,Right> strip<Left, Right>(<Left|Right>(Return) newFunc)
            => Stripped<Return,Left,Right>(this, newFunc);
}

class Stripped<Return, Left, Right>(Invocable<Return> prev, <Right|Left>(Return) func)
        extends ChainingInvocable<Left|Right,Return>(prev, func)
        satisfies StrippedChain<Left,Right> {}

class RightStep<NewRight, Left, Right>(Invocable<Left|Right> prev, NewRight(Right) func)
        satisfies StrippedChain<Left,NewRight> {
    shared actual NewRight|Left do() => let (prevResult = prev.do()) if (is Right prevResult) then func(prevResult) else prevResult;
}

class LeftStep<NewLeft, Left, Right>(Invocable<Left|Right> prev, NewLeft(Left) func)
        satisfies StrippedChain<NewLeft,Right> {
    shared actual NewLeft|Right do() => let (prevResult = prev.do()) if (is Left prevResult) then func(prevResult) else prevResult;
}

class LRStep<NewLeft, NewRight, Left, Right>(Invocable<Left|Right> prev, NewLeft(Left) lFunc, NewRight(Right) rFunc)
        satisfies StrippedChain<NewLeft,NewRight> {
    shared actual NewLeft|NewRight do() => switch (prevResult = prev.do()) case (is Left) lFunc(prevResult)
    else rFunc(prevResult);
}

"Initial stripping step for a chain, that divides incomming argument's (union) type into ´Left´ and ´Right` types"
shared StrippedChain<Left,Right> strip<Left, Right>(Left|Right arguments)
        => object extends IdentityInvocable<Left|Right>(arguments) satisfies StrippedChain<Left,Right> {};

"Initial stripping step, that chains the argument to the function, and strip its result type.
 It is just a shortcut for `[[chain]](arguments).[[strip]](func)`"
shared StrippedChain<Left,Right> chainStrip<Left, Right, Arguments>(Arguments arguments, <Left|Right>(Arguments) func)
        => object extends FunctionInvocable<Left|Right,Arguments>(arguments, func) satisfies StrippedChain<Left,Right> {};
