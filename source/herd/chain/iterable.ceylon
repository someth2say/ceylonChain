import herd.chain {
    identityEach,
    lastParamToFirst
}

shared interface IIterable<Return, Arguments, Element> satisfies IChainable<Return,Arguments>
        given Return satisfies {Element*}
{
    //TODO Consider translating IChainable<X satisfies Iterable...> to IIterable
    shared default IChainable<Boolean,Arguments> any(Boolean(Element) selecting) => Chainable<Boolean,Arguments,Return>(this, shuffle(Return.any)(selecting));
    shared default IIterable<{Element*},Arguments,Element> by(Integer step) => IterableChainable<{Element*},Arguments,Return,Element>(this, shuffle(Return.by)(step));
    shared default IIterable<{Element|Other*},Arguments,Element|Other> chain<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other) given OtherAbsent satisfies Null => IterableChainable<{Element|Other*},Arguments,Return,Element|Other>(this, shuffle(Return.chain<Other,OtherAbsent>)(other));
    shared default ISpreadable<CollectResult[],Arguments> collect<CollectResult>(CollectResult(Element) collecting) => Spreadable<CollectResult[],Arguments,Return>(this, shuffle(Return.collect<CollectResult>)(collecting));
    shared default IChainable<Boolean,Arguments> contains(Object element) => Chainable<Boolean,Arguments,Return>(this, shuffle(Return.contains)(element));
    shared default IChainable<Integer,Arguments> count(Boolean(Element) selecting) => Chainable<Integer,Arguments,Return>(this, shuffle(Return.count)(selecting));
    shared default IIterable<{Element&Object|Default*},Arguments,Element&Object|Default> defaultNullElements<Default>(Default defaultValue) given Default satisfies Object => IterableChainable<{Element&Object|Default*},Arguments,Return,Element&Object|Default>(this, shuffle(Return.defaultNullElements<Default>)(defaultValue));
    shared default IIterable<Return,Arguments,Element> each(Anything(Element) operation) => IterableChainable<Return,Arguments,Return,Element>(this, identityEach<Return,Element>(operation));
    shared default IChainable<Boolean,Arguments> every(Boolean(Element) operation) => Chainable<Boolean,Arguments,Return>(this, shuffle(Return.every)(operation));
    shared default IIterable<{Element*},Arguments,Element> filter(Boolean(Element) operation) => IterableChainable<{Element*},Arguments,Return,Element>(this, shuffle(Return.filter)(operation));
    shared default IChainable<Element?,Arguments> find(Boolean(Element&Object) operation) => Chainable<Element?,Arguments,Return>(this, shuffle(Return.find)(operation));
    shared default IChainable<Element?,Arguments> findLast(Boolean(Element&Object) operation) => Chainable<Element?,Arguments,Return>(this, shuffle(Return.findLast)(operation));
    shared default IIterable<{NewResult*},Arguments,NewResult> flatMap<NewResult, OtherAbsent>(Iterable<NewResult,OtherAbsent>(Element) collecting)
            given OtherAbsent satisfies Null => IterableChainable<{NewResult*},Arguments,Return,NewResult>(this, shuffle(Return.flatMap<NewResult,OtherAbsent>)(collecting));
    shared default IChainable<NewResult,Arguments> fold<NewResult>(NewResult initial, NewResult(NewResult, Element) operation) => Chainable<NewResult,Arguments,Return>(this, lastParamToFirst(Return.fold<NewResult>)(initial)(operation));
    shared default IIterable<{Element|Other*},Arguments,Element|Other> follow<Other>(Other head) => IterableChainable<{Element|Other*},Arguments,Return,Element|Other>(this, shuffle(Return.follow<Other>)(head));
    shared default IChainable<Map<Element&Object,Integer>,Arguments> frequencies() => Chainable<Map<Element&Object,Integer>,Arguments,Return>(this, shuffle(Return.frequencies)());
    shared default IChainable<Element?,Arguments> getFromFirst(Integer index) => Chainable<Element?,Arguments,Return>(this, shuffle(Return.getFromFirst)(index));
    shared default IChainable<Map<Group,[Element+]>,Arguments> group<Group>(Group?(Element)grouping) given Group satisfies Object => Chainable<Map<Group,[Element+]>,Arguments,Return>(this, shuffle(Return.group<Group>)(grouping));
    shared default IChainable<Range<Integer>|[],Arguments> indexes() => Chainable<Range<Integer>|[],Arguments,Return>(this, shuffle(Return.indexes)());
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
