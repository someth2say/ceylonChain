import herd.chain {
    identityEach,
    lastParamToFirst
}

shared interface IIterable<Return, Arguments, Element> satisfies IChainable<Return,Arguments>
        given Return satisfies {Element*}
{
    shared default IChainable<Boolean,Arguments> any(Boolean(Element) operation) => Chainable<Boolean,Arguments,Return>(this, shuffle(Return.any)(operation));
    shared default IIterable<{Element*},Arguments,Element> by(Integer step) => IterableChainable<{Element*},Arguments,Return,Element>(this, shuffle(Return.by)(step));
    //  chain
    shared default ISpreadable<CollectResult[],Arguments> collect<CollectResult>(CollectResult(Element) collecting) => Spreadable<CollectResult[],Arguments,Return>(this, shuffle(Return.collect<CollectResult>)(collecting));
    //  contains
    //  count
    //  defaultNullElements
    shared default IIterable<Return,Arguments,Element> each(Anything(Element) operation) => IterableChainable<Return,Arguments,Return,Element>(this, identityEach<Return,Element>(operation));
    shared default IChainable<Boolean,Arguments> every(Boolean(Element) operation) => Chainable<Boolean,Arguments,Return>(this, shuffle(Return.every)(operation));
    shared default IIterable<{Element*},Arguments,Element> filter(Boolean(Element) operation) => IterableChainable<{Element*},Arguments,Return,Element>(this, shuffle(Return.filter)(operation));
    //    find
    //    findLast
    //    flatMap
    shared default IChainable<NewResult,Arguments> fold<NewResult>(NewResult initial, NewResult(NewResult, Element) operation) => Chainable<NewResult,Arguments,Return>(this, lastParamToFirst(Return.fold<NewResult>)(initial)(operation));
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
    shared default IIterable<{NewReturn*},Arguments,NewReturn> map<NewReturn>(NewReturn(Element) operation) => IterableChainable<{NewReturn*},Arguments,Return,NewReturn>(this, shuffle(Return.map<NewReturn>)(operation));
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
class IterableChainable<NewReturn, Arguments, PrevReturn, NewReturnItem>(IInvocable<PrevReturn> prevCallable, NewReturn(PrevReturn) func)
        extends Chainable<NewReturn,Arguments,PrevReturn>(prevCallable, func)
        satisfies IIterable<NewReturn,Arguments,NewReturnItem>
        given NewReturn satisfies {NewReturnItem*} {}

class ChainStartIterable<Return, Arguments, FuncParam>(Return(*Arguments) func, Arguments arguments)
        extends ChainStart<Return,Arguments>(func, arguments)
        satisfies IIterable<Return,Arguments,FuncParam>
        given Return satisfies {FuncParam*}
        given Arguments satisfies Anything[] {}

shared IIterable<Return,Arguments,FuncParam> chainIterable<Return, Arguments, FuncParam>(Return(*Arguments) func, Arguments arguments) given Return satisfies {FuncParam*}
        given Arguments satisfies Anything[] => ChainStartIterable(func, arguments);
