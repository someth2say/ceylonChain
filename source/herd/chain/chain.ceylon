"Basic interface to substitute `Callable`"
shared interface IInvocable<out Return, in Arguments>
{
    "Actually invoke the callable with specified arguments."
    shared formal Return with(Arguments arguments) ;
}

"Basic implementation for an IInvocable"
class Invocable<out Return, in Arguments>(Return(Arguments) func) satisfies IInvocable<Return,Arguments>
{
    shared actual default Return with(Arguments arguments) => func(arguments);
}

"Chaining Callable is like a Callable, but adding method chaining functionality.
 If Callable interface were not restricted, we may replace the 'with' method with the invocation operation, and make this class satisfies Callable.
 IChainable offers basic method for chaining callables"
shared interface IChainable<Return, in Arguments> satisfies IInvocable<Return,Arguments> {

    shared default IChainable<NewReturn,Arguments> \ithen<NewReturn>(NewReturn(Return) newFunc) => Chainable(this, newFunc);
    shared default IOptionable<NewReturn,Arguments> thenOptionally<NewReturn>(NewReturn(Return&Object) newFunc) => Optionable(this, newFunc);
    shared default ISpreadable<NewReturn,Arguments> thenSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => Spreadable(this, newFunc);
    shared default IIterable<NewReturn,Arguments,FuncReturn> thenIterable<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => IterableChainable(this, newFunc);

    shared default IChainable<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => \ithen(newFunc);
    shared default IOptionable<NewReturn,Arguments> optionallyTo<NewReturn>(NewReturn(Return&Object) newFunc) => thenOptionally(newFunc);
    shared default ISpreadable<NewReturn,Arguments> toSpreadable<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => thenSpreadable(newFunc);

}

"The simplest chaining callable, just calling the previous chaing before calling the function parameter"
class Chainable<Return, in Arguments, PrevReturn>(IInvocable<PrevReturn,Arguments> prevCallable, Return(PrevReturn) func) satisfies IChainable<Return,Arguments> {
    shared actual Return with(Arguments arguments) => let (prevResult = prevCallable.with(arguments)) func(prevResult);
}

"IOptionable is just a tag interface, separating chaining callables that can return nullable types. "
shared interface IOptionable<Return, in Arguments> satisfies IChainable<Return?,Arguments> {}

"Basic class implementing IOptionable. Optionable actually implements the existence checking capability."
class Optionable<NewReturn, in Arguments, Return>(IInvocable<Return?,Arguments> prevCallable, NewReturn(Return&Object) func) satisfies IOptionable<NewReturn,Arguments> {
    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevCallable.with(arguments)) if (exists prevResult) then func(prevResult) else null;
}

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

shared R(T)(F)(S) lastParamToFirst<R, F, S, T>(R(F)(S)(T) func) => (S s)(F f)(T t) => func(t)(s)(f);

shared Return appliedIdentity<Return>(Anything(Return) step)(Return item) {
    step(item);
    return item;
}

shared Result identityEach<Result, Item>(Anything(Item) step)(Result iterable) given Result satisfies {Item*} {
    iterable.each(step);
    return iterable;
}

shared interface IIterable<IterableReturn, in Arguments, IterableItem> satisfies IChainable<IterableReturn,Arguments>
        given IterableReturn satisfies {IterableItem*}
{
    //  any
    //  by
    //  chain
    shared default ISpreadable<CollectResult[],Arguments> collect<CollectResult>(CollectResult(IterableItem) collecting) => Spreadable<CollectResult[],Arguments,IterableReturn>(this, shuffle(IterableReturn.collect<CollectResult>)(collecting));
    //  contains
    //  count
    //  defaultNullElements
    shared default IIterable<IterableReturn,Arguments,IterableItem> each(Anything(IterableItem) operation) => IterableChainable(this, identityEach<IterableReturn,IterableItem>(operation));
    //    every
    //    filter
    //    find
    //    findLast
    //    flatMap
    shared default IChainable<FoldResult,Arguments> fold<FoldResult>(FoldResult initial, FoldResult(FoldResult, IterableItem) operation) => Chainable(this, lastParamToFirst(IterableReturn.fold<FoldResult>)(initial)(operation));
    //    follow
    //    frequencies
    //    getFromFirst
    //    group
    //    indexes
    //    interpose
    //    iterator
    //    locate
    //    locateLast
    //    locations
    //    longerThan
    shared default IIterable<{NewReturn*},Arguments,NewReturn> map<NewReturn>(NewReturn(IterableItem) operation) => IterableChainable(this, shuffle(IterableReturn.map<NewReturn>)(operation));
    //    max
    //    narrow
    //    partition
    //    product
    //    reduce
    //    repeat
    //    scan
    //    select
    //    sequence
    //    shorterThan
    //    skip
    //    skipWhile
    //    sort
    //    spread
    //    summarize
    //    tabulate
    //    take
    //    takeWhile

}

"MappingSpreadable actually implemente the mappingfunctionality"
class IterableChainable<NewReturn, in Arguments, PrevReturn, NewReturnItem>(IInvocable<PrevReturn,Arguments> prevCallable, NewReturn(PrevReturn) func)
        extends Chainable<NewReturn,Arguments,PrevReturn>(prevCallable, func)
        satisfies IIterable<NewReturn,Arguments,NewReturnItem>
        given NewReturn satisfies {NewReturnItem*} {}

class ChainStartIterable<Return, in Arguments, FuncParam>(Return(Arguments) func)
        extends ChainStart<Return,Arguments>(func)
        satisfies IIterable<Return,Arguments,FuncParam>
        given Return satisfies {FuncParam*} {}

shared IIterable<Return,Arguments,FuncParam> chainIterable<Return, in Arguments, FuncParam>(Return(Arguments) func) given Return satisfies {FuncParam*} => ChainStartIterable(func);

"Like SpreadingChainable, but also provides the spreading capability to the next chain step."
class SpreadingSpreadable<NewReturn, in Arguments, Return>(IInvocable<Return,Arguments> prevSpreadable, NewReturn(*Return) func) satisfies ISpreadable<NewReturn,Arguments>
        given Return satisfies [Anything*]
        given NewReturn satisfies [Anything*]
{
    shared actual NewReturn with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) func(*prevResult);
}

// Spreading optional is currently disabled: Should find a way to express Null|*Type
//"SpreadingOptionable mixes both capabilities: Spreading and exisxtence checking"
//class SpreadingOptionable<NewReturn,in Arguments,Return>(IInvocable<Return?,Arguments> prevSpreadable, NewReturn(* Return) func) satisfies IOptionable<NewReturn,Arguments> given Return satisfies Anything[] {
//    shared actual NewReturn? with(Arguments arguments) => let (prevResult = prevSpreadable.with(arguments)) if (exists prevResult) then func(*prevResult) else null;
//}

// Chain starts
"Initial step for a Chaining Callable. Allow to chain with next step, but adding no extra capabilities"
shared IChainable<Return,Arguments> chain<Return, in Arguments>(Return(Arguments) func) => ChainStart(func);
shared IChainable<Return,Arguments> chain2<Return, Return1, in Arguments>(Return1(Arguments) func1, Return(Return1) func2) => ChainStart(func1).to(func2);
shared IChainable<Return,Arguments> chain3<Return, Return1, Return2, in Arguments>(Return1(Arguments) func1, Return2(Return1) func2, Return(Return2) func3) => ChainStart(func1).to(func2).to(func3);

class ChainStart<Return, in Arguments>(Return(Arguments) func) extends Invocable<Return,Arguments>(func) satisfies IChainable<Return,Arguments> {}

"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared ISpreadable<Return,Arguments> chainSpreadable<Return, in Arguments>(Return(Arguments) func) given Return satisfies Anything[] => ChainStartSpread(func);

class ChainStartSpread<Return, in Arguments>(Return(Arguments) func) extends Invocable<Return,Arguments>(func) satisfies ISpreadable<Return,Arguments>
        given Return satisfies Anything[] {
    shared actual Return with(Arguments arguments) => (super of Invocable<Return,Arguments>).with(arguments);
}


"Initial step for a Chaining Callable, but adding spreading capabilities, so result can be spread to next step."
shared IOptionable<Return,Arguments?> chainOptional<Return, in Arguments>(Return(Arguments&Object) func) => ChainStartOptional<Return,Arguments?>(func);

class ChainStartOptional<Return, in Arguments>(Return(Arguments&Object) func) satisfies IOptionable<Return,Arguments> {
    shared actual Return? with(Arguments arguments) => if (exists arguments) then func(arguments) else null;
}




