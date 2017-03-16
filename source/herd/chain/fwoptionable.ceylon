"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IFwOptionable<Return, in Arguments> satisfies IFwChainable<Return?,Arguments> {}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class FwOptionable<NewReturn, in Arguments, Return>(IFwInvocable<Return?> prevCallable, NewReturn(Return&Object) func) satisfies IFwOptionable<NewReturn,Arguments> {
    shared actual NewReturn? do() => let (prevResult = prevCallable.do()) if (exists prevResult) then func(prevResult) else null;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IFwOptionable<Return,Arguments> fwChainOptional<Return, in Arguments>(Return(*Arguments) func, Anything[]? arguments) given Arguments satisfies Anything[] => FwChainStartOptional<Return,Arguments>(func, arguments);

class FwChainStartOptional<Return, in Arguments>(Return(*Arguments) func, Anything[]? arguments) satisfies IFwOptionable<Return,Arguments>
        given Arguments satisfies Anything[] {
    shared actual Return? do() => if (exists arguments, is Arguments arguments) then func(*arguments) else null;
}
