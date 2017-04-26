"Invocable chain step that provides capability for providing chain arguments.
 As this is part of a backward chain, arguments are provided at the end of the chain, in the [[do]] method.
 Example:
 <pre>
    IBwInvocable<String,Integer> bwch = ...;
    String str = bwcw.do();
 </pre>"
shared interface IInvocable<out Return>
{
    "Actually invokes the chain, with the values set at first chain step"
    shared formal Return do() ;
}

abstract class ChainStart<out Return, Arguments>(Return(Arguments) func, Arguments arguments)
        satisfies IInvocable<Return>
{
    shared actual Return do() => func(arguments);
}

abstract class SpreadingChainStart<out Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        satisfies IInvocable<Return>
        given Arguments satisfies Anything[]
{
    shared actual Return do() => func(*arguments);
}

abstract class ChainStep<out Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(PrevReturn) func)
        satisfies IInvocable<Return> {
    shared actual Return do() => let (prevResult = prev.do()) func(prevResult);
}

abstract class SpreadingChainStep<out Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(*PrevReturn) func)
        satisfies IInvocable<Return>
        given PrevReturn satisfies Anything[] {
    shared actual Return do() => let (prevResult = prev.do()) func(*prevResult);

}