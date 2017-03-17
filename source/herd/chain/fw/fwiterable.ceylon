shared interface IFwIterable<IterableReturn, Arguments, IterableItem> satisfies IFwChainable<IterableReturn,Arguments>
        given IterableReturn satisfies {IterableItem*}
{
    //  any
    //  by
    //  chain
    shared default IFwSpreadable<CollectResult[],Arguments> collect<CollectResult>(CollectResult(IterableItem) collecting) => FwSpreadable<CollectResult[],Arguments,IterableReturn>(this, shuffle(IterableReturn.collect<CollectResult>)(collecting));
    //  contains
    //  count
    //  defaultNullElements
    shared default IFwIterable<IterableReturn,Arguments,IterableItem> each(Anything(IterableItem) operation) => FwIterableChainable<IterableReturn,Arguments,IterableReturn,IterableItem>(this, identityEach<IterableReturn,IterableItem>(operation));
    //    every
    //    filter
    //    find
    //    findLast
    //    flatMap
    shared default IFwChainable<FoldResult,Arguments> fold<FoldResult>(FoldResult initial, FoldResult(FoldResult, IterableItem) operation) => FwChainable<FoldResult,Arguments,IterableReturn>(this, lastParamToFirst(IterableReturn.fold<FoldResult>)(initial)(operation));
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
    shared default IFwIterable<{NewReturn*},Arguments,NewReturn> map<NewReturn>(NewReturn(IterableItem) operation) => FwIterableChainable<{NewReturn*},Arguments,IterableReturn,NewReturn>(this, shuffle(IterableReturn.map<NewReturn>)(operation));
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

//
//Result(Third)(First)(Second) lastParamToFirst<Result, First, Second, Third>(Result(First)(Second)(Third) func) => (Second s)(First f)(Third t) => func(t)(s)(f);
//
//Result identityEach<Result, Item>(Anything(Item) step)(Result iterable) given Result satisfies {Item*} {
//    iterable.each(step);
//    return iterable;
//}


"MappingSpreadable actually implemente the mappingfunctionality"
class FwIterableChainable<NewReturn, Arguments, PrevReturn, NewReturnItem>(IFwInvocable<PrevReturn> prevCallable, NewReturn(PrevReturn) func)
        extends FwChainable<NewReturn,Arguments,PrevReturn>(prevCallable, func)
        satisfies IFwIterable<NewReturn,Arguments,NewReturnItem>
        given NewReturn satisfies {NewReturnItem*} {}

class FwChainStartIterable<Return, Arguments, FuncParam>(Return(*Arguments) func, Arguments arguments)
        extends FwChainStart<Return,Arguments>(func, arguments)
        satisfies IFwIterable<Return,Arguments,FuncParam>
        given Return satisfies {FuncParam*}
        given Arguments satisfies Anything[] {}

shared IFwIterable<Return,Arguments,FuncParam> fwchainIterable<Return, Arguments, FuncParam>(Return(*Arguments) func, Arguments arguments) given Return satisfies {FuncParam*}
        given Arguments satisfies Anything[] => FwChainStartIterable(func, arguments);
