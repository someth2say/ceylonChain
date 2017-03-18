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
