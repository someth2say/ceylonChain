"ISpreadable provide spreading capabilities to chaining callables"
shared interface ISpreadable<Return, Arguments> satisfies IChainable<Return,Arguments> given Return satisfies [Anything*] {
    shared default IChainable<NewReturn,Arguments> thenSpreadTo<NewReturn>(NewReturn(*Return) newFunc) => SpreadingChainable<NewReturn,Arguments,Return>(this, newFunc);
    //shared default IOptionable<NewReturn,Arguments> thenOptionalySpreadTo<NewReturn>(NewReturn(* Return) newFunc) => SpreadingOptionable(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> thenSpreadToSpreadable<NewReturn>(NewReturn(*Return) newFunc) given NewReturn satisfies [Anything*] => SpreadingSpreadable<NewReturn,Arguments,Return>(this, newFunc);

    shared default IChainable<NewReturn,Arguments> spreadTo<NewReturn>(NewReturn(*Return) newFunc) => SpreadingChainable<NewReturn,Arguments,Return>(this, newFunc);
    //shared default IOptionable<NewReturn,Arguments> optionallyToSpreadable<NewReturn>(NewReturn(* Return) newFunc) => SpreadingOptionable(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> spreadToSpreadable<NewReturn>(NewReturn(*Return) newFunc) given NewReturn satisfies [Anything*] => SpreadingSpreadable<NewReturn,Arguments,Return>(this, newFunc);
}

"Basic class implementing ISpreadable.
 This class actually does nothing but being an ISpreadable, because spreading should be done in the results (handled in next chain step). So `spreadTo` methods actually provide the capability."
class Spreadable<NewReturn, Arguments, Return>(IInvocable<Return> prevCallable, NewReturn(Return) func)
        extends Chainable<NewReturn,Arguments,Return>(prevCallable, func)
        satisfies ISpreadable<NewReturn,Arguments>
        given NewReturn satisfies Anything[] {}

"SpreadingChainable actually implemente the spreading functionality"
class SpreadingChainable<NewReturn, Arguments, Return>(IInvocable<Return> prevCallable, NewReturn(*Return) func) satisfies IChainable<NewReturn,Arguments>
        given Return satisfies [Anything*]
{
    shared actual NewReturn do() => let (prevResult = prevCallable.do()) func(*prevResult);

}

"Like SpreadingChainable, but also provides the spreading capability to the next chain step."
class SpreadingSpreadable<NewReturn, Arguments, Return>(IInvocable<Return> prevSpreadable, NewReturn(*Return) func) satisfies ISpreadable<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*]
{
    shared actual NewReturn do() => let (prevResult = prevSpreadable.do()) func(*prevResult);

}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared ISpreadable<Return,Arguments> chainSpreadable<Return, Arguments>(Return(*Arguments) func, Arguments arguments) given Return satisfies Anything[]
        given Arguments satisfies Anything[] => ChainStartSpread(func, arguments);

class ChainStartSpread<Return, Arguments>(Return(*Arguments) func, Arguments arguments) extends Invocable<Return,Arguments>(func, arguments) satisfies ISpreadable<Return,Arguments>
        given Return satisfies Anything[]
        given Arguments satisfies Anything[] {
    shared actual Return do() => (super of Invocable<Return,Arguments>).do();
}

// Spreading optional is currently disabled: Should find a way to express Null|*Type
//"SpreadingOptionable mixes both capabilities: Spreading and exisxtence checking"
//class SpreadingOptionable<NewReturn,in Arguments,Return>(IInvocable<Return?,Arguments> prevSpreadable, NewReturn(* Return) func) satisfies IOptionable<NewReturn,Arguments> given Return satisfies Anything[] {
//    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) if (exists prevResult) then func(*prevResult) else null;
//}
