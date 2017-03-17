"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IOptionable<Return, Arguments> satisfies IChainable<Return|Arguments,Arguments> {}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class Optionable<NewReturn, Arguments, Return, FuncArgs>(IInvocable<Return> prevCallable, NewReturn(FuncArgs) func) satisfies IOptionable<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return do() => let (prevResult = prevCallable.do()) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IOptionable<Return|OtherArgs,Arguments> chainOptional<Return, Arguments, OtherArgs>(Return(*Arguments) func, OtherArgs arguments)
        given Arguments satisfies Anything[] => ChainStartOptional<Return|OtherArgs,Arguments,OtherArgs>(func, arguments);

class ChainStartOptional<Return, Arguments, FuncArgs>(Return(*Arguments) func, FuncArgs arguments) satisfies IOptionable<Return|FuncArgs,Arguments>
        given Arguments satisfies Anything[] {
    shared actual Return|FuncArgs do() => if (exists arguments, is Arguments arguments) then func(*arguments) else arguments;
}
