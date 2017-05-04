"Chain step that provides stripping capabilities: being able to divide an union type in two (Left and Right types),
 so they can be handled independently.

 This the second step in a two-step chain. After first one (stripping), this one allows to apply functions on
 each type, or on both of them at once.

 Example:
 <pre>
    assertEquals(chain(\"1\").strip<Integer,ParseException>(Integer.parse).lTo(Integer.successor).do(),2);
    Integer|ParseException do = chain(\"one\").strip<Integer,ParseException>(Integer.parse).lTo(Integer.successor).do();
    assertIs(do, `ParseException`);
 </pre>"
see(`interface StrippingChain`)
shared interface StrippedChain<Left, Right> satisfies Chain<Left|Right> {
    "Applies the provided function to the incomming value, only if the incomming type satisfies `Right` type"
    shared StrippedChain<Left,NewRight> rTo<NewRight>(NewRight(Right) rFunc)
            => RightStep<NewRight,Left,Right>(this, rFunc);

    "Applies the provided function to the incomming value, only if the incomming type satisfies `Left` type"
    shared StrippedChain<NewLeft,Right> lTo<NewLeft>(NewLeft(Left) lFunc)
            => LeftStep<NewLeft,Left,Right>(this, lFunc);

    "Applies the provided 'lFunc' function to the incomming value, only if the incomming type satisfies `Left` type.
     else, applies 'rFunc' function (as type is expected to match `Right type)"
    shared StrippedChain<NewLeft,NewRight> lrTo<NewLeft, NewRight>(NewLeft(Left) lFunc, NewRight(Right) rFunc)
            => LRStep<NewLeft,NewRight,Left,Right>(this, lFunc, rFunc);
}

"Aspect or trait interface that provide spreading capability. "
see(`interface StrippedChain`)
shared interface StrippingChain<Return>
        satisfies Invocable<Return> {

    "Applies the provided function to the incomming value, and then stripps the return type
     into `Left` and `Right` types, so they can be handled separatelly"
    see (`interface StrippedChain`, `function package.strip`, `function package.chainStrip`)
    shared StrippedChain<Left,Right> strip<Left, Right>(<Left|Right>(Return) newFunc)
            => Stripped<Return,Left,Right>(this, newFunc);
}

class Stripped<Return, Left, Right>(Invocable<Return> prev, <Right|Left>(Return) func)
        extends ChainingInvocable<Left|Right,Return>(prev, func)
        satisfies StrippedChain<Left,Right> {}

class RightStep<NewRight, Left, Right>(Invocable<Left|Right> prev, NewRight(Right) func)
        satisfies StrippedChain<Left,NewRight> {
    "Invokes the chain, applying the last provided function only if the incoming value matches the 'Right' type"
    shared actual Left|NewRight do() => let (prevResult = prev.do()) if (is Right prevResult) then func(prevResult) else prevResult;
}

class LeftStep<NewLeft, Left, Right>(Invocable<Left|Right> prev, NewLeft(Left) func)
        satisfies StrippedChain<NewLeft,Right> {
    "Invokes the chain, applying the last provided function only if the incoming value matches the 'Left' type"
    shared actual NewLeft|Right do() => let (prevResult = prev.do()) if (is Left prevResult) then func(prevResult) else prevResult;
}

class LRStep<NewLeft, NewRight, Left, Right>(Invocable<Left|Right> prev, NewLeft(Left) lFunc, NewRight(Right) rFunc)
        satisfies StrippedChain<NewLeft,NewRight> {
    "Invokes the chain, applying the last 'left' provided function only if the incoming value matches the 'Left' type,
     else, `right` provided function is applied."
    shared actual NewLeft|NewRight do() => switch (prevResult = prev.do())
                                            case (is Left) lFunc(prevResult)
                                            else rFunc(prevResult);
}

"Initial stripping step for a chain, that divides incomming argument's (union) type into 'Left' and 'Right' types"
shared StrippedChain<Left,Right> strip<Left, Right>(Left|Right arguments)
        => object extends IdentityInvocable<Left|Right>(arguments) satisfies StrippedChain<Left,Right> {};

"Initial stripping step, that chains the argument to the function, and strip its resulting type.
 It is just a shortcut for `chain(arguments).strip(func)`"
shared StrippedChain<Left,Right> chainStrip<Left, Right, Arguments>(Arguments arguments, <Left|Right>(Arguments) func)
        => object extends FunctionInvocable<Left|Right,Arguments>(arguments, func) satisfies StrippedChain<Left,Right> {};