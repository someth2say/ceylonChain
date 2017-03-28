"Invocable chain step that provides capability for providing chain arguments.
 As this is part of a backward chain, arguments are provided at the end of the chain, in the [[do]] method.
 Example:
 <pre>
    IBwInvocable<String,Integer> bwch = ...;
    String str = bwcw.do();
 </pre>
 "shared interface IInvocable<out Return>
{
    "Invoke the callable with default arguments."
    shared formal Return do() ;
}

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

abstract class InvocableChain<out Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(PrevReturn) func)
        satisfies IInvocable<Return> {
    shared actual default Return do() => let (prevResult = prev.do()) func(prevResult);
}

abstract class InvocableSpreading<out Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(*PrevReturn) func)
        satisfies IInvocable<Return>
        given PrevReturn satisfies Anything[] {
    shared actual default Return do() => let (prevResult = prev.do()) func(*prevResult);

}