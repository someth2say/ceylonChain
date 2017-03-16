"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IOptionable<Return, in Arguments> satisfies IChainable<Return?,Arguments> {}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class Optionable<NewReturn, in Arguments, Return, FuncArguments>(IInvocable<Return,Arguments> prevCallable, NewReturn(FuncArguments) func) satisfies IOptionable<NewReturn,Arguments> {
    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevCallable.with(arguments)) if (is FuncArguments prevResult) then func(prevResult) else null;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IOptionable<Return,Arguments?> chainOptional<Return, in Arguments>(Return(Arguments) func) => ChainStartOptional<Return,Arguments>(func);

class ChainStartOptional<Return, in Arguments>(Return(Arguments) func) satisfies IOptionable<Return,Anything> {
    shared actual Return? with(Anything arguments) => if (is Arguments arguments) then func(arguments) else null;
}
