"Backward invocable chain step that provides capability for providing chain arguments.
 As this is part of a backward chain, arguments are provided at the end of the chain, in the [[with]] method.
 Example:
 <pre>
    IBwInvocable<String,Integer> bwch = ...;
    String str = bwcw.with(10);
 </pre>
 "
shared interface IBwInvocable<out Return,Arguments>
{
    "Invoke the callable with default arguments."
    shared formal Return with(Arguments args) ;
}

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

abstract class BwInvocableChain<out Return, PrevReturn, Arguments>(IBwInvocable<PrevReturn,Arguments> prev, Return(PrevReturn) func)
        satisfies IBwInvocable<Return,Arguments> {
    shared actual default Return with(Arguments args) => let (prevResult = prev.with(args)) func(prevResult);
}

abstract class BwInvocableSpreading<out Return, PrevReturn, Arguments>(IBwInvocable<PrevReturn,Arguments> prev, Return(*PrevReturn) func)
        satisfies IBwInvocable<Return,Arguments>
        given PrevReturn satisfies Anything[] {
    shared actual default Return with(Arguments args) => let (prevResult = prev.with(args)) func(*prevResult);
}