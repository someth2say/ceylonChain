"Invocable provides capability for be invoked, like a method.
 Type parameter for an Invocable stands for the type returned on invocation.

 Invocation is allways performed through the 'do' method.
 Example:
 <pre>
    Invocable<String> ch = ...;
    String str = ch.do();
 </pre>"
shared interface Invocable<out Return>
{
    "Actually invokes the chain."
    shared formal Return do() ;
}

abstract class IdentityInvocable<Arguments>(Arguments arguments)
        satisfies Invocable<Arguments>
{
    shared actual Arguments do() => arguments;
}

abstract class FunctionInvocable<out Return, Arguments>(Arguments arguments, Return(Arguments) func)
        satisfies Invocable<Return>
{
    shared actual Return do() => func(arguments);
}

abstract class ChainingInvocable<out Return, PrevReturn>(Invocable<PrevReturn> prev, Return(PrevReturn) func)
        satisfies Invocable<Return> {
    shared actual Return do() => let (prevResult = prev.do()) func(prevResult);
}
