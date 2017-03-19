"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IProbing<Return, Arguments> satisfies IInvocable<Return|Arguments> {
    shared default IChaining<Return|Arguments,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => Chaining<Return|Arguments,Arguments,Return>(this, newFunc);
    shared default IProbing<Return|Arguments,Arguments> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc) => Probing<Return|Arguments,Arguments,Return,FuncArgs>(this, newFunc);
    shared default ISpreading<Return|Arguments,Arguments> spread<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => Spreading<Return|Arguments,Arguments,Return>(this, newFunc);
    shared default IIterating<Return|Arguments,Arguments,FuncReturn> iterate<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => Iterating<Return|Arguments,Arguments,Return,FuncReturn>(this, newFunc);
}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class Probing<NewReturn, Arguments, Return, FuncArgs>(IInvocable<Return> prev, NewReturn(FuncArgs) func)
        satisfies IProbing<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return do() => let (prevResult = prev.do()) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IProbing<Return|OtherArgs,Arguments> probe<Return, Arguments, OtherArgs>(Return(*Arguments) func, OtherArgs arguments)

        given Arguments satisfies Anything[]
        => ProbingStart<Return|OtherArgs,Arguments,OtherArgs>(func, arguments);

class ProbingStart<Return, Arguments, FuncArgs>(Return(*Arguments) func, FuncArgs arguments)
        satisfies IProbing<Return|FuncArgs,Arguments>
        given Arguments satisfies Anything[] {
    shared actual Return|FuncArgs do() => if (exists arguments, is Arguments arguments) then func(*arguments) else arguments;
}
