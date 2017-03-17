"Basic interface to substitute `Callable`"
shared interface IFwInvocable<out Return>
{
    "Actually invoke the callable with specified arguments."
    shared formal Return do() ;
}

"Basic implementation for an IInvocable"
class FwInvocable<out Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        satisfies IFwInvocable<Return> given Arguments satisfies Anything[]
{
    shared actual default Return do() => func(*arguments);
}

"Chaining Callable is like a Callable, but adding method chaining functionality.
 If Callable interface were not restricted, we may replace the 'with' method with the invocation operation, and make this class satisfies Callable.
 IChainable offers basic method for chaining callables"
shared interface IFwChainable<Return, Arguments> satisfies IFwInvocable<Return> {

    shared default IFwChainable<NewReturn,Arguments> \ithen<NewReturn>(NewReturn(Return) newFunc) => FwChainable<NewReturn,Arguments,Return>(this, newFunc);
    shared default IFwOptionable<NewReturn|Return,Arguments> thenOptionally<NewReturn,FuncArgs>(NewReturn(FuncArgs) newFunc) => FwOptionable<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
    shared default IFwSpreadable<NewReturn,Arguments> thenSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => FwSpreadable<NewReturn,Arguments,Return>(this, newFunc);
    //TODO: Symplify NewReturn
    shared default IFwIterable<NewReturn,Arguments,FuncReturn> thenIterable<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => FwIterableChainable<NewReturn,Arguments,Return,FuncReturn>(this, newFunc);

    shared default IFwChainable<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => \ithen(newFunc);
    shared default IFwOptionable<NewReturn|Return,Arguments> optionallyTo<NewReturn,FuncArgs>(NewReturn(FuncArgs) newFunc) => thenOptionally(newFunc);
    shared default IFwSpreadable<NewReturn,Arguments> toSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => thenSpreadable(newFunc);

}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class FwChainable<Return, Arguments, PrevReturn>(IFwInvocable<PrevReturn> prevCallable, Return(PrevReturn) func)
        satisfies IFwChainable<Return,Arguments> {
    shared actual Return do() => let (prevResult = prevCallable.do()) func(prevResult);
}

"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IFwChainable<Return,Arguments> fwchain<Return, Arguments>(Return(*Arguments) func, Arguments arguments) given Arguments satisfies Anything[] => FwChainStart(func, arguments);

class FwChainStart<Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        extends FwInvocable<Return,Arguments>(func, arguments)
        satisfies IFwChainable<Return,Arguments>
        given Arguments satisfies Anything[] {}