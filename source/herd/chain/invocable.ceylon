"Basic interface to substitute `Callable`"
shared interface IInvocable<out Return>
{
    "Actually invoke the callable with specified arguments."
    shared formal Return do() ;
}

"Basic implementation for an IInvocable start of chain.
 Note that will ALWAYS spread input arguments"
abstract class InvocableStart<out Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        satisfies IInvocable<Return> given Arguments satisfies Anything[]
{
    shared actual default Return do() => func(*arguments);
}

"Basic implementation for an IInvocable chain step."
abstract class InvocableChain<out Return, PrevReturn>(IInvocable<PrevReturn> prevCallable, Return(PrevReturn) func)
        satisfies IInvocable<Return> {
    shared actual default Return do() => let (prevResult = prevCallable.do()) func(prevResult);
}

"Spreading implementation for an IInvocable chain step."
abstract class InvocableSpreading<out Return, PrevReturn>(IInvocable<PrevReturn> prevCallable, Return(*PrevReturn) func)
        satisfies IInvocable<Return> given PrevReturn satisfies Anything[] {
    shared actual default Return do() => let (prevResult = prevCallable.do()) func(*prevResult);
}