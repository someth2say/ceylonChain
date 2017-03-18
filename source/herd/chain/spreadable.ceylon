"ISpreadable provide spreading capabilities to chaining callables"
shared interface ISpreading<Return, Arguments> satisfies IChainable<Return,Arguments> given Return satisfies [Anything*] {
    shared default IChainable<NewReturn,Arguments> spreadTo<NewReturn>(NewReturn(*Return) newFunc) => SpreadingChainable<NewReturn,Arguments,Return>(this, newFunc);
    //shared default IOptionable<NewReturn,Arguments> optionallyToSpreadable<NewReturn>(NewReturn(* Return) newFunc) => SpreadingOptionable(this, newFunc);
    shared default ISpreading<NewReturn,Arguments> keepSpreading<NewReturn>(NewReturn(*Return) newFunc) given NewReturn satisfies [Anything*] => SpreadingSpreadable<NewReturn,Arguments,Return>(this, newFunc);
}

"Basic class implementing ISpreadable.
 This class actually does nothing but being an ISpreadable, because spreading should be done in the results (handled in next chain step). So `spreadTo` methods actually provide the capability."
class Spreading<NewReturn, Arguments, Return>(IInvocable<Return> prevCallable, NewReturn(Return) func)
        extends Chain<NewReturn,Arguments,Return>(prevCallable, func)
        satisfies ISpreading<NewReturn,Arguments>
        given NewReturn satisfies Anything[] {}

"SpreadingChainable actually implemente the spreading functionality"
class SpreadingChainable<NewReturn, Arguments, Return>(IInvocable<Return> prevCallable, NewReturn(*Return) func) satisfies IChainable<NewReturn,Arguments>
        given Return satisfies [Anything*]
{
    shared actual NewReturn do() => let (prevResult = prevCallable.do()) func(*prevResult);

}

"Like SpreadingChainable, but also provides the spreading capability to the next chain step."
class SpreadingSpreadable<NewReturn, Arguments, Return>(IInvocable<Return> prevSpreadable, NewReturn(*Return) func) satisfies ISpreading<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*]
{
    shared actual NewReturn do() => let (prevResult = prevSpreadable.do()) func(*prevResult);

}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared ISpreading<Return,Arguments> spread<Return, Arguments>(Return(*Arguments) func, Arguments arguments) given Return satisfies Anything[]
        given Arguments satisfies Anything[] => ChainStartSpread(func, arguments);

class ChainStartSpread<Return, Arguments>(Return(*Arguments) func, Arguments arguments) extends Invocable<Return,Arguments>(func, arguments) satisfies ISpreading<Return,Arguments>
        given Return satisfies Anything[]
        given Arguments satisfies Anything[] {
    shared actual Return do() => (super of Invocable<Return,Arguments>).do();
}

// Spreading optional is currently disabled: Should find a way to express Null|*Type
//"SpreadingOptionable mixes both capabilities: Spreading and exisxtence checking"
//class SpreadingOptionable<NewReturn,in Arguments,Return>(IInvocable<Return?,Arguments> prevSpreadable, NewReturn(* Return) func) satisfies IOptionable<NewReturn,Arguments> given Return satisfies Anything[] {
//    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) if (exists prevResult) then func(*prevResult) else null;
//}
