"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IBwProbing<Return, Arguments>
        satisfies IBwInvocable<Return|Arguments,Arguments>
        & IBwIterable<Return|Arguments,Arguments>
        & IBwChainable<Return|Arguments,Arguments>
        & IBwProbable<Return|Arguments,Arguments>
        & IBwSpreadable<Return|Arguments,Arguments>
{}


shared interface IBwProbable<Return, Arguments>
        satisfies IBwInvocable<Return, Arguments> {
    shared default IBwProbing<NewReturn|Return,Arguments> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc)
            => BwProbing<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class BwProbing<NewReturn, Arguments, Return, FuncArgs>(IBwInvocable<Return,Arguments> prev, NewReturn(FuncArgs) func)
        satisfies IBwProbing<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return with(Arguments args) => let (prevResult = prev.with(args)) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

//TODO; Initial steps are very lame! TC is unable to determine Arguments, because it is provided by the 'with' method. This forces user to provide all 3 type parameters
// Also, the meaning for Arguments is "allowed types for the 'with' funcion", so most users will just set Arguments=Anything
"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IBwProbing<Return|Arguments,Arguments> bwprobe<FuncArgs, Return, Arguments>(Return(FuncArgs) func)
        => object satisfies IBwProbing<Return|Arguments,Arguments> {
    shared actual Return|Arguments with(Arguments args) => if (is FuncArgs args) then func(args) else args;
};

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IBwProbing<Return|Arguments,Arguments> bwprobes<FuncArgs, Return, Arguments>(Return(*FuncArgs) func)
        given Arguments satisfies Anything[]
        given FuncArgs satisfies Anything[]
        => object satisfies IBwProbing<Return|Arguments,Arguments> {
    shared actual Return|Arguments with(Arguments args) => if (is FuncArgs args) then func(*args) else args;
};

