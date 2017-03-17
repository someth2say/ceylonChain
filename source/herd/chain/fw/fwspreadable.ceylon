"ISpreadable provide spreading capabilities to chaining callables"
shared interface IFwSpreadable<Return, Arguments> satisfies IFwChainable<Return,Arguments> given Return satisfies [Anything*] {
    shared default IFwChainable<NewReturn,Arguments> thenSpreadTo<NewReturn>(NewReturn(*Return) newFunc) => FwSpreadingChainable<NewReturn,Arguments,Return>(this, newFunc);
    //shared default IOptionable<NewReturn,Arguments> thenOptionalySpreadTo<NewReturn>(NewReturn(* Return) newFunc) => SpreadingOptionable(this, newFunc);
    shared default IFwSpreadable<NewReturn,Arguments> thenSpreadToSpreadable<NewReturn>(NewReturn(*Return) newFunc) given NewReturn satisfies [Anything*] => FwSpreadingSpreadable<NewReturn,Arguments,Return>(this, newFunc);

    shared default IFwChainable<NewReturn,Arguments> spreadTo<NewReturn>(NewReturn(*Return) newFunc) => FwSpreadingChainable<NewReturn,Arguments,Return>(this, newFunc);
    //shared default IOptionable<NewReturn,Arguments> optionallyToSpreadable<NewReturn>(NewReturn(* Return) newFunc) => SpreadingOptionable(this, newFunc);
    shared default IFwSpreadable<NewReturn,Arguments> spreadToSpreadable<NewReturn>(NewReturn(*Return) newFunc) given NewReturn satisfies [Anything*] => FwSpreadingSpreadable<NewReturn,Arguments,Return>(this, newFunc);
}

"Basic class implementing ISpreadable.
 This class actually does nothing but being an ISpreadable, because spreading should be done in the results (handled in next chain step). So `spreadTo` methods actually provide the capability."
class FwSpreadable<NewReturn, Arguments, Return>(IFwInvocable<Return> prevCallable, NewReturn(Return) func)
        extends FwChainable<NewReturn,Arguments,Return>(prevCallable, func)
        satisfies IFwSpreadable<NewReturn,Arguments>
        given NewReturn satisfies Anything[] {}

"SpreadingChainable actually implemente the spreading functionality"
class FwSpreadingChainable<NewReturn, Arguments, Return>(IFwInvocable<Return> prevCallable, NewReturn(*Return) func) satisfies IFwChainable<NewReturn,Arguments>
        given Return satisfies [Anything*]
{
    shared actual NewReturn do() => let (prevResult = prevCallable.do()) func(*prevResult);

}

"Like SpreadingChainable, but also provides the spreading capability to the next chain step."
class FwSpreadingSpreadable<NewReturn, Arguments, Return>(IFwInvocable<Return> prevSpreadable, NewReturn(*Return) func) satisfies IFwSpreadable<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*]
{
    shared actual NewReturn do() => let (prevResult = prevSpreadable.do()) func(*prevResult);

}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IFwSpreadable<Return,Arguments> fwChainSpreadable<Return, Arguments>(Return(*Arguments) func, Arguments arguments) given Return satisfies Anything[]
        given Arguments satisfies Anything[] => FwChainStartSpread(func, arguments);

class FwChainStartSpread<Return, Arguments>(Return(*Arguments) func, Arguments arguments) extends FwInvocable<Return,Arguments>(func, arguments) satisfies IFwSpreadable<Return,Arguments>
        given Return satisfies Anything[]
        given Arguments satisfies Anything[] {
    shared actual Return do() => (super of FwInvocable<Return,Arguments>).do();
}

// Spreading optional is currently disabled: Should find a way to express Null|*Type
//"SpreadingOptionable mixes both capabilities: Spreading and exisxtence checking"
//class SpreadingOptionable<NewReturn,in Arguments,Return>(IInvocable<Return?,Arguments> prevSpreadable, NewReturn(* Return) func) satisfies IOptionable<NewReturn,Arguments> given Return satisfies Anything[] {
//    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) if (exists prevResult) then func(*prevResult) else null;
//}
