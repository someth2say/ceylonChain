import herd.chain {
    identityEach,
    lastParamToFirst
}

"Interface for a chain step wich return type can be iterated"
shared interface IIterating<Return, Arguments, Element> satisfies IInvocable<Return>
        given Return satisfies {Element*}
{
    shared default IChaining<NewReturn,Arguments> to<NewReturn>(NewReturn(Return) newFunc) => Chaining<NewReturn,Arguments,Return>(this, newFunc);
    shared default IProbing<NewReturn|Return,Arguments> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc) => Probing<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
    shared default ISpreading<NewReturn,Arguments> spread<NewReturn>(NewReturn(Return) newFunc) given NewReturn satisfies [Anything*] => Spreading<NewReturn,Arguments,Return>(this, newFunc);
    shared default IIterating<NewReturn,Arguments,FuncReturn> iterate<NewReturn, FuncReturn>(NewReturn(Return) newFunc) given NewReturn satisfies {FuncReturn*} => Iterating<NewReturn,Arguments,Return,FuncReturn>(this, newFunc);

    shared default IChaining<Boolean,Arguments> any(Boolean(Element) selecting) => Chaining<Boolean,Arguments,Return>(this, shuffle(Return.any)(selecting));
    shared default IIterating<{Element*},Arguments,Element> by(Integer step) => Iterating<{Element*},Arguments,Return,Element>(this, shuffle(Return.by)(step));
    shared default IIterating<{Element|Other*},Arguments,Element|Other> chain<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other)
            given OtherAbsent satisfies Null => Iterating<{Element|Other*},Arguments,Return,Element|Other>(this, shuffle(Return.chain<Other,OtherAbsent>)(other));
    shared default ISpreading<CollectResult[],Arguments> collect<CollectResult>(CollectResult(Element) collecting) => Spreading<CollectResult[],Arguments,Return>(this, shuffle(Return.collect<CollectResult>)(collecting));
    shared default IChaining<Boolean,Arguments> contains(Object element) => Chaining<Boolean,Arguments,Return>(this, shuffle(Return.contains)(element));
    shared default IChaining<Integer,Arguments> count(Boolean(Element) selecting) => Chaining<Integer,Arguments,Return>(this, shuffle(Return.count)(selecting));
    shared default IIterating<{Element&Object|Default*},Arguments,Element&Object|Default> defaultNullElements<Default>(Default defaultValue)
            given Default satisfies Object => Iterating<{Element&Object|Default*},Arguments,Return,Element&Object|Default>(this, shuffle(Return.defaultNullElements<Default>)(defaultValue));
    shared default IIterating<Return,Arguments,Element> each(Anything(Element) operation) => Iterating<Return,Arguments,Return,Element>(this, identityEach<Return,Element>(operation));
    shared default IChaining<Boolean,Arguments> every(Boolean(Element) operation) => Chaining<Boolean,Arguments,Return>(this, shuffle(Return.every)(operation));
    shared default IIterating<{Element*},Arguments,Element> filter(Boolean(Element) operation) => Iterating<{Element*},Arguments,Return,Element>(this, shuffle(Return.filter)(operation));
    shared default IChaining<Element?,Arguments> find(Boolean(Element&Object) operation) => Chaining<Element?,Arguments,Return>(this, shuffle(Return.find)(operation));
    shared default IChaining<Element?,Arguments> findLast(Boolean(Element&Object) operation) => Chaining<Element?,Arguments,Return>(this, shuffle(Return.findLast)(operation));
    shared default IIterating<{NewResult*},Arguments,NewResult> flatMap<NewResult, OtherAbsent>(Iterable<NewResult,OtherAbsent>(Element) collecting)
            given OtherAbsent satisfies Null => Iterating<{NewResult*},Arguments,Return,NewResult>(this, shuffle(Return.flatMap<NewResult,OtherAbsent>)(collecting));
    shared default IChaining<NewResult,Arguments> fold<NewResult>(NewResult initial, NewResult(NewResult, Element) operation) => Chaining<NewResult,Arguments,Return>(this, lastParamToFirst(Return.fold<NewResult>)(initial)(operation));
    shared default IIterating<{Element|Other*},Arguments,Element|Other> follow<Other>(Other head) => Iterating<{Element|Other*},Arguments,Return,Element|Other>(this, shuffle(Return.follow<Other>)(head));
    //TODO Consider translating IChaining<Map...> to IIterating
    shared default IChaining<Map<Element&Object,Integer>,Arguments> frequencies() => Chaining<Map<Element&Object,Integer>,Arguments,Return>(this, shuffle(Return.frequencies)());
    shared default IChaining<Element?,Arguments> getFromFirst(Integer index) => Chaining<Element?,Arguments,Return>(this, shuffle(Return.getFromFirst)(index));
    //TODO Consider translating IChaining<Map...> to IIterating
    shared default IChaining<Map<Group,[Element+]>,Arguments> group<Group>(Group?(Element) grouping)
            given Group satisfies Object => Chaining<Map<Group,[Element+]>,Arguments,Return>(this, shuffle(Return.group<Group>)(grouping));
    //TODO Consider translating IChaining<Range...> to IIterating
    shared default IChaining<Range<Integer>|[],Arguments> indexes() => Chaining<Range<Integer>|[],Arguments,Return>(this, shuffle(Return.indexes)());
    //    indexes
    //    interpose
    //    iterator
    //    locate
    //    locateLast
    //    locations
    //    longerThan
    shared default IIterating<{NewReturn*},Arguments,NewReturn> map<NewReturn>(NewReturn(Element) operation) => Iterating<{NewReturn*},Arguments,Return,NewReturn>(this, shuffle(Return.map<NewReturn>)(operation));
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

"An Iterating start is just a tipical start, but given its return should be an iterable"
class Iterating<NewReturn, Arguments, PrevReturn, NewReturnItem>(IInvocable<PrevReturn> prev, NewReturn(PrevReturn) func)
        extends InvocableChain<NewReturn,PrevReturn>(prev, func)
satisfies IIterating<NewReturn,Arguments,NewReturnItem>
        given NewReturn satisfies {NewReturnItem*} {}

class IteratingStart<Return, Arguments, FuncParam>(Return(*Arguments) func, Arguments arguments)
        extends InvocableStart<Return,Arguments>(func, arguments)
        satisfies IIterating<Return,Arguments,FuncParam>
        given Return satisfies {FuncParam*}
        given Arguments satisfies Anything[] {}

"Iterable start"
shared IIterating<Return,Arguments,FuncParam> iterate<Return, Arguments, FuncParam>(Return(*Arguments) func, Arguments arguments) given Return satisfies {FuncParam*}
        given Arguments satisfies Anything[] => IteratingStart(func, arguments);