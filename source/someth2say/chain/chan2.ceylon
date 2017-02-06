"ChainingCallable is like a Callable, but adding method chaining functionality.
 If Callable interface was not restricted, we may replace the 'with' method with the invocation operation, and make this class satisfies Callable"
shared interface IInvocable<out Return,in Arguments>
{
    "Actually invoke the callable with specified arguments."
    shared formal Return with(Arguments arguments);
}

shared class Invocable<out Return,in Arguments>(Return(Arguments) func) satisfies IInvocable<Return,Arguments>
{
    shared actual Return with(Arguments arguments) => func(arguments);
}

shared interface IChainable<Return,in Arguments> satisfies IInvocable<Return,Arguments> given Return satisfies Anything {
    shared default IChainable<NewReturn,Arguments> chain<NewReturn>(NewReturn(Return) newFunc) => Chainable(this, newFunc);
    shared default IOptionable<NewReturn,Arguments> chainOptional<NewReturn>(NewReturn(Return&Object) newFunc) => Optionable(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> chainSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies Anything[] => Spreadable(this, newFunc);
}

shared interface ISpreadable<Return,in Arguments> satisfies IChainable<Return,Arguments> given Return satisfies Anything[] {
    shared default IChainable<NewReturn,Arguments> spread<NewReturn>(NewReturn(* Return) newFunc) => SpreadingChainable(this, newFunc);
    shared default IOptionable<NewReturn,Arguments> spreadOptional<NewReturn>(NewReturn(* Return) newFunc) => SpreadingOptionable(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> spreadSpreadable<NewReturn>(NewReturn(* Return) newFunc) given NewReturn satisfies Anything[] => SpreadingSpreadable(this, newFunc);
}

shared class Chainable<Return,in Arguments,PrevReturn>(IInvocable<PrevReturn,Arguments> prevCallable, Return(PrevReturn) func) satisfies IInvocable<Return,Arguments>&IChainable<Return,Arguments> {
    shared actual Return with(Arguments arguments) => func(prevCallable.with(arguments));
}

shared IChainable<Return,Arguments> chain2<Return,in Arguments>(Return(Arguments) func) => ChainStart(func);
shared ISpreadable<Return,Arguments> chainSpread<Return,in Arguments>(Return(Arguments) func) given Return satisfies Anything[] => ChainStartSpread(func);

shared class ChainStart<Return,in Arguments>(Return(Arguments) func) extends Invocable<Return,Arguments>(func) satisfies IInvocable<Return,Arguments>&IChainable<Return,Arguments> {}

shared class ChainStartSpread<Return,in Arguments>(Return(Arguments) func) satisfies IInvocable<Return,Arguments>&ISpreadable<Return,Arguments> given Return satisfies Anything[] {
    shared actual Return with(Arguments arguments) => func(arguments);
}

shared interface IOptionable<Return,in Arguments> satisfies IInvocable<Return?,Arguments>&IChainable<Return?,Arguments> {}

shared class Optionable<NewReturn,in Arguments,Return>(IInvocable<Return?,Arguments> prevCallable, NewReturn(Return&Object) func) satisfies IOptionable<NewReturn,Arguments> {
    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevCallable.with(arguments)) if (exists prevResult) then func(prevResult) else null;
}

shared class Spreadable<NewReturn,in Arguments,Return>(IInvocable<Return,Arguments> prevCallable, NewReturn(Return) func) satisfies ISpreadable<NewReturn,Arguments> given NewReturn satisfies Anything[] {
    shared actual NewReturn with(Arguments arguments) => let (Return prevResult = prevCallable.with(arguments)) func(prevResult);
}

class SpreadingChainable<NewReturn,in Arguments,Return>(IInvocable<Return,Arguments> prevSpreadable, NewReturn(* Return) func) satisfies IChainable<NewReturn,Arguments> given Return satisfies Anything[] {
    shared actual NewReturn with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) func(*prevResult);
}

class SpreadingOptionable<NewReturn,in Arguments,Return>(IInvocable<Return?,Arguments> prevSpreadable, NewReturn(* Return) func) satisfies IOptionable<NewReturn,Arguments> given Return satisfies Anything[] {
    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) if (exists prevResult) then func(*prevResult) else null;
}

class SpreadingSpreadable<NewReturn,in Arguments,Return>(IInvocable<Return,Arguments> prevSpreadable, NewReturn(* Return) func) satisfies ISpreadable<NewReturn,Arguments> given Return satisfies Anything[]
given NewReturn satisfies Anything[] {
    shared actual NewReturn with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) func(*prevResult);
}

