
shared interface IIterable<IterableReturn, Arguments, IterableItem> satisfies IChainable<IterableReturn,Arguments>
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


Result(Third)(First)(Second) lastParamToFirst<Result, First, Second, Third>(Result(First)(Second)(Third) func) => (Second s)(First f)(Third t) => func(t)(s)(f);

Result identityEach<Result, Item>(Anything(Item) step)(Result iterable) given Result satisfies {Item*} {
    iterable.each(step);
    return iterable;
}


"MappingSpreadable actually implemente the mappingfunctionality"
class IterableChainable<NewReturn, Arguments, PrevReturn, NewReturnItem>(IInvocable<PrevReturn,Arguments> prevCallable, NewReturn(PrevReturn) func)
        extends Chainable<NewReturn,Arguments,PrevReturn>(prevCallable, func)
        satisfies IIterable<NewReturn,Arguments,NewReturnItem>
        given NewReturn satisfies {NewReturnItem*} {}

class ChainStartIterable<Return, Arguments, FuncParam>(Return(Arguments) func)
        extends ChainStart<Return,Arguments>(func)
        satisfies IIterable<Return,Arguments,FuncParam>
        given Return satisfies {FuncParam*} {}

shared IIterable<Return,Arguments,FuncParam> chainIterable<Return, Arguments, FuncParam>(Return(Arguments) func) given Return satisfies {FuncParam*} => ChainStartIterable(func);
