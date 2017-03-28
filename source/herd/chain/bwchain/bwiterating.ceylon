import herd.chain {
    identityEach,
    lastParamToFirst
}

"Backward chain step that provides iterating capabilities.
 That is, provide the ability to perform same operations that user can perform onto an iterable..
 Iterating chain steps require a function whose return type can be iterated (i.o.w, satisfies {Anything*})

 Example:
 <pre>
    Range<Integer> foo(Integer i) => (1..i); // Note Range<...> satisfies Iterable
    IBwIterating<Range<Integer>,Integer,Integer> bi = bwiterate(foo);
    IBwIterating<{Integer*},Integer,Integer> fi = bi.filter(Integer.even).map(Integer.successor);
    IBwIterating<{Integer*},Integer,Integer> pr = fi.each(print); // 'each' performs the function over each element, and returns the same
    pr.with(10); // Print all numbers in {3,5,7,9,11}, and returns this same sequence
 </pre>
 "
shared interface IBwIterating<Return, Arguments, Element>
        satisfies IBwInvocable<Return,Arguments>
        & IBwIterable<Return,Arguments>
        & IBwChainable<Return,Arguments>
        & IBwProbable<Return,Arguments>
        & IBwSpreadable<Return,Arguments>
        given Return satisfies {Element*}
{
    shared default IBwChaining<Boolean,Arguments> any(Boolean(Element) selecting) => BwChaining<Boolean,Arguments,Return>(this, shuffle(Return.any)(selecting));
    shared default IBwIterating<{Element*},Arguments,Element> by(Integer step) => BwIterating<{Element*},Arguments,Return,Element>(this, shuffle(Return.by)(step));
    shared default IBwIterating<{Element|Other*},Arguments,Element|Other> chain<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other)
            given OtherAbsent satisfies Null => BwIterating<{Element|Other*},Arguments,Return,Element|Other>(this, shuffle(Return.chain<Other,OtherAbsent>)(other));
    shared default IBwSpreading<CollectResult[],Arguments> collect<CollectResult>(CollectResult(Element) collecting) => BwSpreading<CollectResult[],Arguments,Return>(this, shuffle(Return.collect<CollectResult>)(collecting));
    shared default IBwChaining<Boolean,Arguments> contains(Object element) => BwChaining<Boolean,Arguments,Return>(this, shuffle(Return.contains)(element));
    shared default IBwChaining<Integer,Arguments> count(Boolean(Element) selecting) => BwChaining<Integer,Arguments,Return>(this, shuffle(Return.count)(selecting));
    shared default IBwIterating<{Element&Object|Default*},Arguments,Element&Object|Default> defaultNullElements<Default>(Default defaultValue)
            given Default satisfies Object => BwIterating<{Element&Object|Default*},Arguments,Return,Element&Object|Default>(this, shuffle(Return.defaultNullElements<Default>)(defaultValue));
    shared default IBwIterating<Return,Arguments,Element> each(Anything(Element) operation) => BwIterating<Return,Arguments,Return,Element>(this, identityEach<Return,Element>(operation));
    shared default IBwChaining<Boolean,Arguments> every(Boolean(Element) operation) => BwChaining<Boolean,Arguments,Return>(this, shuffle(Return.every)(operation));
    shared default IBwIterating<{Element*},Arguments,Element> filter(Boolean(Element) operation) => BwIterating<{Element*},Arguments,Return,Element>(this, shuffle(Return.filter)(operation));
    shared default IBwChaining<Element?,Arguments> find(Boolean(Element&Object) operation) => BwChaining<Element?,Arguments,Return>(this, shuffle(Return.find)(operation));
    shared default IBwChaining<Element?,Arguments> findLast(Boolean(Element&Object) operation) => BwChaining<Element?,Arguments,Return>(this, shuffle(Return.findLast)(operation));
    shared default IBwIterating<{NewResult*},Arguments,NewResult> flatMap<NewResult, OtherAbsent>(Iterable<NewResult,OtherAbsent>(Element) collecting)
            given OtherAbsent satisfies Null => BwIterating<{NewResult*},Arguments,Return,NewResult>(this, shuffle(Return.flatMap<NewResult,OtherAbsent>)(collecting));
    shared default IBwChaining<NewResult,Arguments> fold<NewResult>(NewResult initial, NewResult(NewResult, Element) operation) => BwChaining<NewResult,Arguments,Return>(this, lastParamToFirst(Return.fold<NewResult>)(initial)(operation));
    shared default IBwIterating<{Element|Other*},Arguments,Element|Other> follow<Other>(Other head) => BwIterating<{Element|Other*},Arguments,Return,Element|Other>(this, shuffle(Return.follow<Other>)(head));
    //TODO Consider translating IBwChaining<Map...> to IBwIterating
    shared default IBwChaining<Map<Element&Object,Integer>,Arguments> frequencies() => BwChaining<Map<Element&Object,Integer>,Arguments,Return>(this, shuffle(Return.frequencies)());
    shared default IBwChaining<Element?,Arguments> getFromFirst(Integer index) => BwChaining<Element?,Arguments,Return>(this, shuffle(Return.getFromFirst)(index));
    //TODO Consider translating IBwChaining<Map...> to IBwIterating
    shared default IBwChaining<Map<Group,[Element+]>,Arguments> group<Group>(Group?(Element) grouping)
            given Group satisfies Object => BwChaining<Map<Group,[Element+]>,Arguments,Return>(this, shuffle(Return.group<Group>)(grouping));
    //TODO Consider translating IBwChaining<Range...> to IBwIterating
    shared default IBwChaining<Range<Integer>|[],Arguments> indexes() => BwChaining<Range<Integer>|[],Arguments,Return>(this, shuffle(Return.indexes)());
    //    indexes
    //    interpose
    //    iterator
    //    locate
    //    locateLast
    //    locations
    //    longerThan
    shared default IBwIterating<{NewReturn*},Arguments,NewReturn> map<NewReturn>(NewReturn(Element) operation) => BwIterating<{NewReturn*},Arguments,Return,NewReturn>(this, shuffle(Return.map<NewReturn>)(operation));
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

"Aspect or trait interface that provide backward iterating capability. "
shared interface IBwIterable<Return, Arguments> satisfies IBwInvocable<Return,Arguments> {
    shared default IBwIterating<NewReturn,Arguments,FuncReturn> iterate<NewReturn, FuncReturn>(NewReturn(Return) newFunc)
            given NewReturn satisfies {FuncReturn*}
            => BwIterating<NewReturn,Arguments,Return,FuncReturn>(this, newFunc);
}


class BwIterating<NewReturn, Arguments, PrevReturn, NewReturnItem>(IBwInvocable<PrevReturn,Arguments> prev, NewReturn(PrevReturn) func)
        extends BwInvocableChain<NewReturn,PrevReturn,Arguments>(prev, func)
        satisfies IBwIterating<NewReturn,Arguments,NewReturnItem>
        given NewReturn satisfies {NewReturnItem*} {}

"Initial iterable step for a backward chain, whose results can be iterated."
shared IBwIterating<Return,Arguments,FuncParam> bwiterate<Return, Arguments, FuncParam>(Return(Arguments) func)
        given Return satisfies {FuncParam*}
        => object extends BwInvocableStart<Return,Arguments>(func)
        satisfies IBwIterating<Return,Arguments,FuncParam> {};

"Initial iterable step for a backward chain, whose results can be iterated.
  The only difference with [[bwiterate]] is that [[bwiterates]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared IBwIterating<Return,Arguments,FuncParam> bwiterates<Return, Arguments, FuncParam>(Return(*Arguments) func)
        given Return satisfies {FuncParam*}
        given Arguments satisfies Anything[]
        => object extends BwInvocableStartSpreading<Return,Arguments>(func)
        satisfies IBwIterating<Return,Arguments,FuncParam> {};
