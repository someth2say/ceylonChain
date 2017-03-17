"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IOptionable<Return, Arguments> satisfies IChainable<Return,Arguments> {}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class Optionable<NewReturn, Arguments, Return, FuncArguments>(IInvocable<Return,Arguments> prevCallable, NewReturn(FuncArguments) func) satisfies IOptionable<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return with(Arguments arguments) => let (prevResult = prevCallable.with(arguments)) if (is FuncArguments prevResult) then func(prevResult) else prevResult;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IOptionable<Return|Arguments,Arguments> chainOptional<Return, Arguments, FuncArguments>(Return(FuncArguments) func) => ChainStartOptional<Return,Arguments,FuncArguments>(func);

class ChainStartOptional<Return, Arguments, FuncArguments>(Return(FuncArguments) func) satisfies IOptionable<Return|Arguments,Arguments> {
    shared actual Return|Arguments with(Arguments arguments) => if (is FuncArguments arguments) then func(arguments) else arguments;
}
