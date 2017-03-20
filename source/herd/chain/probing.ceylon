"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IProbing<Return, Arguments>
        satisfies IInvocable<Return|Arguments>
        & IIterable<Return|Arguments,Arguments>
        & IChainable<Return|Arguments,Arguments>
        & IProbable<Return|Arguments,Arguments>
        & ISpreadable<Return|Arguments,Arguments> {}

shared interface IProbable<Return, Arguments>
        satisfies IInvocable<Return> {
    shared default IProbing<NewReturn|Return,Arguments> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc)
            => Probing<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);

}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class Probing<NewReturn, Arguments, Return, FuncArgs>(IInvocable<Return> prev, NewReturn(FuncArgs) func)
        satisfies IProbing<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return do() => let (prevResult = prev.do()) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IProbing<Return|GivenArgs,Arguments> probe<Return, Arguments, GivenArgs>(Return(Arguments) func, GivenArgs arguments)
        => object satisfies IProbing<Return|GivenArgs,Arguments> {
    shared actual Return|GivenArgs do() => if (is Arguments arguments) then func(arguments) else arguments;
};

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IProbing<Return|GivenArgs,Arguments> probes<Return, Arguments, GivenArgs>(Return(*Arguments) func, GivenArgs arguments)
        given Arguments satisfies Anything[]
        => object satisfies IProbing<Return|GivenArgs,Arguments> {
    shared actual Return|GivenArgs do() => if (is Arguments arguments) then func(*arguments) else arguments;
};