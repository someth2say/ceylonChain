"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IFwOptionable<Return, Arguments> satisfies IFwChainable<Return|Arguments,Arguments> {}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class FwOptionable<NewReturn, Arguments, Return, FuncArgs>(IFwInvocable<Return> prevCallable, NewReturn(FuncArgs) func) satisfies IFwOptionable<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return do() => let (prevResult = prevCallable.do()) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IFwOptionable<Return|OtherArgs,Arguments> fwChainOptional<Return, Arguments, OtherArgs>(Return(*Arguments) func, OtherArgs arguments)
        given Arguments satisfies Anything[] => FwChainStartOptional<Return|OtherArgs,Arguments,OtherArgs>(func, arguments);

class FwChainStartOptional<Return, Arguments, FuncArgs>(Return(*Arguments) func, FuncArgs arguments) satisfies IFwOptionable<Return|FuncArgs,Arguments>
        given Arguments satisfies Anything[] {
    shared actual Return|FuncArgs do() => if (exists arguments, is Arguments arguments) then func(*arguments) else arguments;
}
