"ChainingCallable is like a Callable, but adding method chaining functionality.
 If Callable interface was not restricted, we may replace the 'with' method with the invocation operation, and make this class satisfies Callable"
shared interface ChainingCallable<out ChainReturn,in ChainArguments>
{
    shared formal ChainReturn with(ChainArguments arguments);
    shared ChainingCallable<NewChainReturn,ChainArguments> andThen<NewChainReturn>(NewChainReturn(ChainReturn) newFunc) => ChainCompose(this, newFunc);
    shared ChainingCallable<NewChainReturn?,ChainArguments> ifExistsThen<NewChainReturn>(NewChainReturn(ChainReturn&Object) newFunc) => ChainExists(this, newFunc);
    shared ChainingCallable<NewChainReturn?,ChainArguments> ifSpreadThen<NewChainReturn>(Callable<NewChainReturn,ChainReturn> newFunc) => ChainSpread(this, newFunc);
}

"chain method is just a sugar method to create a ChainingCallable."
shared ChainingCallable<Return,Arguments> chain<out Return,in Arguments>(Return(Arguments) func) => ChainStart(func);

"The start of the chain. Just acepts a single function, and begins the chain with it"
class ChainStart<out Return,in Arguments>(Return(Arguments) func) satisfies ChainingCallable<Return,Arguments>
{
    shared actual Return with(Arguments arguments) => func(arguments);
}

"Basic chain step. Just forwards the value from the previous chain to a function, and returns its value when invoked."
class ChainCompose<out PrevReturn,out Return,in Arguments>(ChainingCallable<PrevReturn,Arguments> prevChain, Return(PrevReturn) func) satisfies ChainingCallable<Return,Arguments>
{
    shared actual default Return with(Arguments arguments) => func(prevChain.with(arguments));
}

"Conditional chain step. Only forwards the previous chain's value to the function if previous chain returned a non-null. Else, the return value is null."
class ChainExists<out PrevReturn,out Return,in Arguments>(ChainingCallable<PrevReturn,Arguments> prevChain, Return(PrevReturn&Object) func) satisfies ChainingCallable<Return?,Arguments>
{
    shared actual default Return? with(Arguments arguments) => let (value prev = prevChain.with(arguments)) if (exists prev) then func(prev) else null;
}

"Spreading chain step. Only forwards the previous chain's value to the function if previous chain returned a non-null. Else, the return value is null.
 This behaviour is an unfortunate consecuence of the architecture. Type-safe calling the 'ifSpreadThen' method of a needs validating that the _previous_ chain link returning type is 'spreadable'."
class ChainSpread<out PrevReturn,out Return,in Arguments>(ChainingCallable<PrevReturn,Arguments> prevChain, Callable<Return,PrevReturn> func) satisfies ChainingCallable<Return?,Arguments>
{
    shared actual default Return? with(Arguments arguments) => let (value prev = prevChain.with(arguments)) if (is Anything[] prev) then func(*prev) else null;
}
