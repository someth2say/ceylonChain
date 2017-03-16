"Basic interface to substitute `Callable`"
shared interface IInvocable<out Return, in Arguments>
{
    "Actually invoke the callable with specified arguments."
    shared formal Return with(Arguments arguments) ;

}

"Basic implementation for an IInvocable"
class Invocable<out Return, in Arguments>(Return(Arguments) func)
        satisfies IInvocable<Return,Arguments>
{
    shared actual default Return with(Arguments arguments) => func(arguments);

}

"Chaining Callable is like a Callable, but adding method chaining functionality.
 If Callable interface were not restricted, we may replace the 'with' method with the invocation operation, and make this class satisfies Callable.
 IChainable offers basic method for chaining callables"
shared interface IChainable<Return, in Arguments> satisfies IInvocable<Return,Arguments> {

    shared default IChainable<NewReturn,Arguments> \ithen<NewReturn>(NewReturn(Return) newFunc) => Chainable(this, newFunc);
    shared default IOptionable<NewReturn,Arguments> thenOptionally<NewReturn>(NewReturn(Return&Object) newFunc) => Optionable(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> thenSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => Spreadable(this, newFunc);
    shared default IIterable<NewReturn,Arguments,FuncReturn> thenIterable<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => IterableChainable(this, newFunc);

    shared default IChainable<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => \ithen(newFunc);
    shared default IOptionable<NewReturn,Arguments> optionallyTo<NewReturn>(NewReturn(Return&Object) newFunc) => thenOptionally(newFunc);
    shared default ISpreadable<NewReturn,Arguments> toSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => thenSpreadable(newFunc);
}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class Chainable<Return, in Arguments, PrevReturn>(IInvocable<PrevReturn,Arguments> prevCallable, Return(PrevReturn) func)
        satisfies  IChainable<Return,Arguments> & IInvocable<Return,Arguments> {
    shared actual Return with(Arguments arguments) => let (prevResult = prevCallable.with(arguments)) func(prevResult);
}

"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IChainable<Return,Arguments> chain<Return, in Arguments>(Return(Arguments) func) => ChainStart(func);

class ChainStart<Return, in Arguments>(Return(Arguments) func)
        extends Invocable<Return,Arguments>(func)
        satisfies IChainable<Return,Arguments> {}



