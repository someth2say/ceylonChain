"Basic interface to substitute `Callable`"
shared interface IInvocable<out Return>
{
    "Invoke the callable with default arguments."
    shared formal Return do() ;

}

"Basic implementation for an IInvocable start of chain."
abstract class InvocableStart<out Return, Arguments>(Return(Arguments) func, Arguments arguments)
        satisfies IInvocable<Return>
{
    shared actual default Return do() => func(arguments);
}

abstract class InvocableStartSpreading<out Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        satisfies IInvocable<Return>
        given Arguments satisfies Anything[]
{
    shared actual default Return do() => func(*arguments);
}

"Basic implementation for an IInvocable chain step."
abstract class InvocableChain<out Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(PrevReturn) func)
        satisfies IInvocable<Return> {
    shared actual default Return do() => let (prevResult = prev.do()) func(prevResult);
}

"Spreading implementation for an IInvocable chain step."
abstract class InvocableSpreading<out Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(*PrevReturn) func)
        satisfies IInvocable<Return>
        given PrevReturn satisfies Anything[] {
    shared actual default Return do() => let (prevResult = prev.do()) func(*prevResult);

}