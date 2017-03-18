
shared interface IChainToOthers<Return,Arguments> satisfies IInvocable<Return>{
    shared default ITrying<NewReturn|Return,Arguments> \itry<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc) => Trying<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => Spreading<NewReturn,Arguments,Return>(this, newFunc);
    shared default IIterating<NewReturn,Arguments,FuncReturn> iterate<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => Iterating<NewReturn,Arguments,Return,FuncReturn>(this, newFunc);
}

"Chaining Callable is like a Callable, but adding method chaining functionality.
 IChainable offers basic method for chaining callables"
shared interface IChaining<Return, Arguments> satisfies IInvocable<Return>{
    shared default IChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => Chaining<NewReturn,Arguments,Return>(this, newFunc);
}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class Chaining<Return, Arguments, PrevReturn>(IInvocable<PrevReturn> prevCallable, Return(PrevReturn) func)
        extends InvocableChain<Return,PrevReturn>(prevCallable, func)
        satisfies IChaining<Return,Arguments>&IChainToOthers<Return, Arguments>{}

"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IChaining<Return,Arguments>&IChainToOthers<Return, Arguments> chain<Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        given Arguments satisfies Anything[] => ChainingStart(func, arguments);

class ChainingStart<Return, Arguments>(Return(*Arguments) func, Arguments arguments)
        extends InvocableStart<Return,Arguments>(func, arguments)
        satisfies  IChaining<Return,Arguments>&IChainToOthers<Return, Arguments>
        given Arguments satisfies Anything[] {}