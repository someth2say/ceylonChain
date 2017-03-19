
"Chaining Callable is like a Callable, but adding method chaining functionality.
 IChainable offers basic method for chaining callables"
shared interface IChaining<Return, Arguments> satisfies IInvocable<Return>{
    shared default IChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => Chaining<NewReturn,Arguments,Return>(this, newFunc);
    shared default IProbing<NewReturn|Return,Arguments> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc) => Probing<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => Spreading<NewReturn,Arguments,Return>(this, newFunc);
    shared default IIterating<NewReturn,Arguments,FuncReturn> iterate<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => Iterating<NewReturn,Arguments,Return,FuncReturn>(this, newFunc);
}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class Chaining<Return, Arguments, PrevReturn>(IInvocable<PrevReturn> prev, Return(PrevReturn) func)
        extends InvocableChain<Return,PrevReturn>(prev, func)
        satisfies IChaining<Return,Arguments>{}

"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IChaining<Return,Arguments> chain<Return, Arguments>(Return(Arguments) func, Arguments arguments)
//        given Arguments satisfies Anything[]
        => ChainingStart(func, arguments);

class ChainingStart<Return, Arguments>(Return(Arguments) func, Arguments arguments)
        extends InvocableStart<Return,Arguments>(func, arguments)
        satisfies  IChaining<Return,Arguments>
//        given Arguments satisfies Anything[]
{}