"Basic interface to substitute `Callable`"
shared interface IInvocable<out Return>
{
    "Actually invoke the callable with specified arguments."
    shared formal Return do() ;
}

"Basic implementation for an IInvocable"
class Invocable<out Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        satisfies IInvocable<Return> given Arguments satisfies Anything[]
{
    shared actual default Return do() => func(*arguments);
}

"Chaining Callable is like a Callable, but adding method chaining functionality.
 If Callable interface were not restricted, we may replace the 'with' method with the invocation operation, and make this class satisfies Callable.
 IChainable offers basic method for chaining callables"
shared interface IChainable<Return, Arguments> satisfies IInvocable<Return> {

    shared default IChainable<NewReturn,Arguments> \ithen<NewReturn>(NewReturn(Return) newFunc) => Chainable<NewReturn,Arguments,Return>(this, newFunc);
    shared default IOptionable<NewReturn|Return,Arguments> thenOptionally<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc) => Optionable<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> thenSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => Spreadable<NewReturn,Arguments,Return>(this, newFunc);
    shared default IIterable<NewReturn,Arguments,FuncReturn> thenIterable<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => IterableChainable<NewReturn,Arguments,Return,FuncReturn>(this, newFunc);

    shared default IChainable<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => \ithen(newFunc);
    shared default IOptionable<NewReturn|Return,Arguments> optionallyTo<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc) => thenOptionally(newFunc);
    shared default ISpreadable<NewReturn,Arguments> toSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => thenSpreadable(newFunc);

}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class Chainable<Return, Arguments, PrevReturn>(IInvocable<PrevReturn> prevCallable, Return(PrevReturn) func)
        satisfies IChainable<Return,Arguments> {
    shared actual Return do() => let (prevResult = prevCallable.do()) func(prevResult);
}

"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IChainable<Return,Arguments> chain<Return, Arguments>(Return(*Arguments) func, Arguments arguments) given Arguments satisfies Anything[] => ChainStart(func, arguments);

class ChainStart<Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        extends Invocable<Return,Arguments>(func, arguments)
        satisfies IChainable<Return,Arguments>
        given Arguments satisfies Anything[] {}