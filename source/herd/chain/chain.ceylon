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
 IChainable offers basic method for chaining callables"
shared interface IChainable<Return, Arguments> satisfies IInvocable<Return> {

    shared default IChainable<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => Chain<NewReturn,Arguments,Return>(this, newFunc);
    shared default ITrying<NewReturn|Return,Arguments> \itry<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc) => Trying<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => Spreading<NewReturn,Arguments,Return>(this, newFunc);
    shared default IIterable<NewReturn,Arguments,FuncReturn> iterate<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => Iterating<NewReturn,Arguments,Return,FuncReturn>(this, newFunc);

}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class Chain<Return, Arguments, PrevReturn>(IInvocable<PrevReturn> prevCallable, Return(PrevReturn) func)
        satisfies IChainable<Return,Arguments> {
    shared actual Return do() => let (prevResult = prevCallable.do()) func(prevResult);
}

"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IChainable<Return,Arguments> chain<Return, Arguments>(Return(*Arguments) func, Arguments arguments) given Arguments satisfies Anything[] => ChainStart(func, arguments);

class ChainStart<Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        extends Invocable<Return,Arguments>(func, arguments)
        satisfies IChainable<Return,Arguments>
        given Arguments satisfies Anything[] {}