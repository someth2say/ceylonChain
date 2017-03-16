
"ISpreadable provide spreading capabilities to chaining callables"
shared interface ISpreadable<Return, in Arguments> satisfies IChainable<Return,Arguments> given Return satisfies [Anything*] {
    shared default IChainable<NewReturn,Arguments> thenSpreadTo<NewReturn>(NewReturn(*Return) newFunc) => SpreadingChainable(this, newFunc);
    //shared default IOptionable<NewReturn,Arguments> thenOptionalySpreadTo<NewReturn>(NewReturn(* Return) newFunc) => SpreadingOptionable(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> thenSpreadToSpreadable<NewReturn>(NewReturn(*Return) newFunc) given NewReturn satisfies [Anything*] => SpreadingSpreadable(this, newFunc);

    shared default IChainable<NewReturn,Arguments> spreadTo<NewReturn>(NewReturn(*Return) newFunc) => SpreadingChainable(this, newFunc);
    //shared default IOptionable<NewReturn,Arguments> optionallyToSpreadable<NewReturn>(NewReturn(* Return) newFunc) => SpreadingOptionable(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> spreadToSpreadable<NewReturn>(NewReturn(*Return) newFunc) given NewReturn satisfies [Anything*] => SpreadingSpreadable(this, newFunc);
}

"Basic class implementing ISpreadable.
 This class actually does nothing but being an ISpreadable, because spreading should be done in the results (handled in next chain step). So `spreadTo` methods actually provide the capability."
class Spreadable<NewReturn, in Arguments, Return>(IInvocable<Return,Arguments> prevCallable, NewReturn(Return) func)
        extends Chainable<NewReturn,Arguments,Return>(prevCallable, func)
        satisfies ISpreadable<NewReturn,Arguments>
        given NewReturn satisfies Anything[] {}

"SpreadingChainable actually implemente the spreading functionality"
class SpreadingChainable<NewReturn, in Arguments, Return>(IInvocable<Return,Arguments> prevCallable, NewReturn(*Return) func) satisfies IChainable<NewReturn,Arguments>
        given Return satisfies [Anything*]
{
    shared actual NewReturn with(Arguments arguments) => let (prevResult = prevCallable.with(arguments)) func(*prevResult);
}

"Like SpreadingChainable, but also provides the spreading capability to the next chain step."
class SpreadingSpreadable<NewReturn, in Arguments, Return>(IInvocable<Return,Arguments> prevSpreadable, NewReturn(*Return) func) satisfies ISpreadable<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*]
{
    shared actual NewReturn with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) func(*prevResult);
}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared ISpreadable<Return,Arguments> chainSpreadable<Return, in Arguments>(Return(Arguments) func) given Return satisfies Anything[] => ChainStartSpread(func);

class ChainStartSpread<Return, in Arguments>(Return(Arguments) func) extends Invocable<Return,Arguments>(func) satisfies ISpreadable<Return,Arguments>
        given Return satisfies Anything[] {
    shared actual Return with(Arguments arguments) => (super of Invocable<Return,Arguments>).with(arguments);
}

// Spreading optional is currently disabled: Should find a way to express Null|*Type
//"SpreadingOptionable mixes both capabilities: Spreading and exisxtence checking"
//class SpreadingOptionable<NewReturn,in Arguments,Return>(IInvocable<Return?,Arguments> prevSpreadable, NewReturn(* Return) func) satisfies IOptionable<NewReturn,Arguments> given Return satisfies Anything[] {
//    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) if (exists prevResult) then func(*prevResult) else null;
//}
