"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IProbing<Return, Arguments> satisfies IInvocable<Return|Arguments> {

    shared default IChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(Return|Arguments) newFunc)
            => Chaining<NewReturn,Arguments,Return|Arguments>(this, newFunc);

    shared default IProbing<NewReturn|FuncArgs|Return|Arguments,Arguments> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc)
            => Probing<NewReturn|FuncArgs,Arguments,Return|Arguments,FuncArgs>(this, newFunc);

    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return|Arguments) newFunc)
            given NewReturn satisfies [Anything*]
            => Spreading<NewReturn,Arguments,Return|Arguments>(this, newFunc);

    shared default IIterating<NewReturn,Arguments,FuncReturn> iterate<NewReturn, FuncReturn>(NewReturn(Return|Arguments) newFunc)
            given NewReturn satisfies {FuncReturn*}
            => Iterating<NewReturn,Arguments,Return|Arguments,FuncReturn>(this, newFunc);
}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class Probing<NewReturn, Arguments, Return, FuncArgs>(IInvocable<Return> prev, NewReturn(FuncArgs) func)
        satisfies IProbing<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return do() => let (prevResult = prev.do()) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IProbing<Return|GivenArgs,Arguments> probe<Return, Arguments, GivenArgs>(Return(Arguments) func, GivenArgs arguments)
//        given Arguments satisfies Anything[]
        => ProbingStart<Return|GivenArgs,Arguments,GivenArgs>(func, arguments);

class ProbingStart<Return, Arguments, FuncArgs>(Return(Arguments) func, FuncArgs arguments)
        satisfies IProbing<Return|FuncArgs,Arguments>
//        given Arguments satisfies Anything[]
{
    shared actual Return|FuncArgs do() => if (is Arguments arguments) then func(arguments) else arguments;
}
