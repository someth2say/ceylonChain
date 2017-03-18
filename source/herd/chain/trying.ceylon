"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface ITrying<Return, Arguments> satisfies IChaining<Return|Arguments,Arguments> {}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class Trying<NewReturn, Arguments, Return, FuncArgs>(IInvocable<Return> prev, NewReturn(FuncArgs) func)
        satisfies ITrying<NewReturn|Return,Arguments> & IChainToOthers<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return do() => let (prevResult = prev.do()) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared ITrying<Return|OtherArgs,Arguments> \itry<Return, Arguments, OtherArgs>(Return(*Arguments) func, OtherArgs arguments)
        given Arguments satisfies Anything[]
        => TryingStart<Return|OtherArgs,Arguments,OtherArgs>(func, arguments);

class TryingStart<Return, Arguments, FuncArgs>(Return(*Arguments) func, FuncArgs arguments)
        satisfies ITrying<Return|FuncArgs,Arguments> & IChainToOthers<Return|FuncArgs,Arguments>
        given Arguments satisfies Anything[] {
    shared actual Return|FuncArgs do() => if (exists arguments, is Arguments arguments) then func(*arguments) else arguments;
}
