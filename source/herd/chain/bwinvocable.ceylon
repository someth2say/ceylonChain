"Basic interface to substitute `Callable`"
shared interface IBwInvocable<out Return,Arguments>
{
    "Invoke the callable with default arguments."
    shared formal Return with(Arguments args) ;
}

"Basic implementation for an IInvocable start of chain."
abstract class BwInvocableStart<out Return, Arguments>(Return(Arguments) func)
        satisfies IBwInvocable<Return,Arguments>
{
    shared actual default Return with(Arguments args) => func(args);
}

abstract class BwInvocableStartSpreading<out Return, Arguments>(Return(*Arguments) func)
        satisfies IBwInvocable<Return,Arguments>
        given Arguments satisfies Anything[]
{
    shared actual default Return with(Arguments args) => func(*args);
}

"Basic implementation for an IInvocable chain step."
abstract class BwInvocableChain<out Return, PrevReturn, Arguments>(IBwInvocable<PrevReturn,Arguments> prev, Return(PrevReturn) func)
        satisfies IBwInvocable<Return,Arguments> {
    shared actual default Return with(Arguments args) => let (prevResult = prev.with(args)) func(prevResult);
}

"Spreading implementation for an IInvocable chain step."
abstract class BwInvocableSpreading<out Return, PrevReturn, Arguments>(IBwInvocable<PrevReturn,Arguments> prev, Return(*PrevReturn) func)
        satisfies IBwInvocable<Return,Arguments>
        given PrevReturn satisfies Anything[] {
    shared actual default Return with(Arguments args) => let (prevResult = prev.with(args)) func(*prevResult);

}