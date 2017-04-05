import herd.chain {
    identityEach,
    lastParamToFirst
}

"Chain step that provides iterating capabilities.
 That is, provide the ability to perform same operations that user can perform onto an iterable.
 Iterating chain steps require a function whose return type can be iterated (i.o.w, satisfies {Anything*}).
 Example:
 <pre>
    Range<Integer> foo(Integer i) => (1..i); // Note Range<...> satisfies Iterable
    IBwIterating<Range<Integer>,Integer,Integer> bi = iterate(10,foo);
    IBwIterating<{Integer*},Integer,Integer> fi = bi.filter(Integer.even).map(Integer.successor);
    IBwIterating<{Integer*},Integer,Integer> pr = fi.each(print); // 'each' performs the function over each element, and returns the same
    pr.do(); // Print all numbers in {3,5,7,9,11}, and returns this same sequence
 </pre>
 "
shared interface IIterating<Return, Element, Absent=Null>
        satisfies IInvocable<Return>
        & IIterable<Return>
        & IChainable<Return>
        & IProbable<Return>
        & ISpreadable<Return>
        & IHandleable<Return>
        given Absent satisfies Null
        given Return satisfies Iterable<Element,Absent>
{
    shared default IChaining<Boolean> any(Boolean(Element) selecting) => Chaining<Boolean,Return>(this, shuffle(Return.any)(selecting));
    shared default IIterating<Iterable<Element,Absent>,Element> by(Integer step) => Iterating<Iterable<Element,Absent>,Return,Element>(this, shuffle(Return.by)(step));
    shared default IIterating<{Element|Other*},Element|Other> chain<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other)
            given OtherAbsent satisfies Null => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.chain<Other,OtherAbsent>)(other));
    shared default IIterating<Result[],Result> collect<Result>(Result(Element) collecting) => Iterating<Result[],Return,Result>(this, shuffle(Return.collect<Result>)(collecting));
    shared default IChaining<Boolean> contains(Object element) => Chaining<Boolean,Return>(this, shuffle(Return.contains)(element));
    shared default IChaining<Integer> count(Boolean(Element) selecting) => Chaining<Integer,Return>(this, shuffle(Return.count)(selecting));
    shared default IIterating<{Element&Object|Default*},Element&Object|Default> defaultNullElements<Default>(Default defaultValue)
            given Default satisfies Object => Iterating<{Element&Object|Default*},Return,Element&Object|Default>(this, shuffle(Return.defaultNullElements<Default>)(defaultValue));
    shared default IIterating<Return,Element> each(Anything(Element) operation) => Iterating<Return,Return,Element>(this, identityEach<Return,Element>(operation));
    shared default IChaining<Boolean> every(Boolean(Element) operation) => Chaining<Boolean,Return>(this, shuffle(Return.every)(operation));
    shared default IIterating<{Element*},Element> filter(Boolean(Element) operation) => Iterating<{Element*},Return,Element>(this, shuffle(Return.filter)(operation));
    shared default IChaining<Element?> find(Boolean(Element&Object) operation) => Chaining<Element?,Return>(this, shuffle(Return.find)(operation));
    shared default IChaining<Element?> findLast(Boolean(Element&Object) operation) => Chaining<Element?,Return>(this, shuffle(Return.findLast)(operation));
    shared default IIterating<{NewResult*},NewResult> flatMap<NewResult, OtherAbsent>(Iterable<NewResult,OtherAbsent>(Element) collecting)
            given OtherAbsent satisfies Null => Iterating<{NewResult*},Return,NewResult>(this, shuffle(Return.flatMap<NewResult,OtherAbsent>)(collecting));
    shared default IChaining<Result> fold<Result>(Result initial, Result(Result, Element) accumulating) => Chaining<Result,Return>(this, lastParamToFirst(Return.fold<Result>)(initial)(accumulating));
    shared default IIterating<{Element|Other*},Element|Other> follow<Other>(Other head) => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.follow<Other>)(head));
    shared default IIterating<Map<Element&Object,Integer>,Element&Object->Integer> frequencies() => Iterating<Map<Element&Object,Integer>,Return,Element&Object->Integer>(this, shuffle(Return.frequencies)());
    shared default IChaining<Element?> getFromFirst(Integer index) => Chaining<Element?,Return>(this, shuffle(Return.getFromFirst)(index));
    shared default IIterating<Map<Group,[Element+]>,Group->[Element+]> group<Group>(Group?(Element) grouping)
            given Group satisfies Object => Iterating<Map<Group,[Element+]>,Return,Group->[Element+]>(this, shuffle(Return.group<Group>)(grouping));
    shared default IIterating<Range<Integer>|[],Integer> indexes() => Iterating<Range<Integer>|[],Return,Integer>(this, shuffle(Return.indexes)());
    shared default IIterating<{Element|Other*},Element|Other> interpose<Other>(Other element, Integer step = 1) => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.interpose<Other>)(element, step));
    shared default IChaining<Iterator<Element>> iterator() => Chaining<Iterator<Element>,Return>(this, shuffle(Return.iterator)());
    shared default IChaining<<Integer->Element&Object>?> locate(Boolean(Element&Object) selecting) => Chaining<<Integer->Element&Object>?,Return>(this, shuffle(Return.locate)(selecting));
    shared default IChaining<<Integer->Element&Object>?> locateLast(Boolean(Element&Object) selecting) => Chaining<<Integer->Element&Object>?,Return>(this, shuffle(Return.locateLast)(selecting));
    shared default IIterating<{<Integer->Element&Object>*},<Integer->Element&Object>> locations(Boolean(Element&Object) selecting)
            => Iterating<{<Integer->Element&Object>*},Return,<Integer->Element&Object>>(this, shuffle(Return.locations)(selecting));
    shared default IChaining<Boolean> longerThan(Integer length) => Chaining<Boolean,Return>(this, shuffle(Return.longerThan)(length));
    shared default IIterating<{NewReturn*},NewReturn> map<NewReturn>(NewReturn(Element) operation) => Iterating<{NewReturn*},Return,NewReturn>(this, shuffle(Return.map<NewReturn>)(operation));
    shared default IChaining<Element|Absent> max(Comparison(Element, Element) comparing) => Chaining<Element|Absent,Return>(this, shuffle(Return.max)(comparing));
    shared default IIterating<{Element&Type*},Element&Type> narrow<Type>() => Iterating<{Element&Type*},Return,Element&Type>(this, shuffle(Return.narrow<Type>)());
    shared default IIterating<Iterable<[Element+],Absent>,[Element+]> partition(Integer length) => Iterating<Iterable<[Element+],Absent>,Return,[Element+]>(this, shuffle(Return.partition)(length));
    shared default IIterating<Iterable<[Element, Other],Absent|OtherAbsent>,[Element, Other]> product<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other)
            given OtherAbsent satisfies Null
            => Iterating<Iterable<[Element, Other],Absent|OtherAbsent>,Return,[Element, Other]>(this, shuffle(Return.product<Other,OtherAbsent>)(other));
    shared default IChaining<Result|Element|Absent> reduce<Result>(Result(Result|Element, Element) accumulating) => Chaining<Result|Element|Absent,Return>(this, shuffle(Return.reduce<Result>)(accumulating));
    shared default IIterating<{Element*},Element> repeat(Integer times) => Iterating<{Element*},Return,Element>(this, shuffle(Return.repeat)(times));
    shared default IIterating<{Result+},Result> scan<Result>(Result initial, Result(Result, Element) accumulating) => Iterating<{Result+},Return,Result>(this, lastParamToFirst(Return.scan<Result>)(initial)(accumulating));
    shared default IIterating<Element[],Element> select(Boolean selecting(Element element)) => Iterating<Element[],Return,Element>(this, shuffle(Return.select)(selecting));
    shared default IIterating<[Element+]|[]&Iterable<Element,Absent>,Element> sequence() => Iterating<[Element+]|[]&Iterable<Element,Absent>,Return,Element>(this, shuffle(Return.sequence)());
    shared default IChaining<Boolean> shorterThan(Integer length) => Chaining<Boolean,Return>(this, shuffle(Return.shorterThan)(length));
    shared default IIterating<{Element*},Element> skip(Integer skipping) => Iterating<{Element*},Return,Element>(this, shuffle(Return.skip)(skipping));
    shared default IIterating<{Element*},Element> skipWhile(Boolean skipping(Element element)) => Iterating<{Element*},Return,Element>(this, shuffle(Return.skipWhile)(skipping));
    shared default IIterating<Element[],Element> sort(Comparison comparing(Element x, Element y)) => Iterating<Element[],Return,Element>(this, shuffle(Return.sort)(comparing));
    //TODO: We are unlucky here, 'spread' method clashes
    //TODO: Consider creating a whole new IIterating, whose arguments are *Args
    shared default IChaining<Iterable<Result,Absent>(*Args)> spreadIterable<Result, Args>(Result(*Args) method(Element element))
            given Args satisfies Anything[]
            => Chaining<Iterable<Result,Absent>(*Args),Return>(this, shuffle(Return.spread<Result,Args>)(method));
    shared default IIterating<Map<Group,Result>,Group->Result> summarize<Group,Result>(Group? grouping(Element element),Result accumulating(Result? partial, Element element))
            given Group satisfies Object
            => Iterating<Map<Group,Result>,Return,Group->Result>(this, shuffle(Return.summarize<Group,Result>)(grouping, accumulating));
    shared default IIterating<Map<Element&Object,Result>,Element&Object->Result> tabulate<Result>(Result collecting(Element key))
            => Iterating<Map<Element&Object,Result>,Return,Element&Object->Result>(this, shuffle(Return.tabulate<Result>)(collecting));
    shared default IIterating<{Element*},Element> take(Integer taking) => Iterating<{Element*},Return,Element>(this, shuffle(Return.take)(taking));
    shared default IIterating<{Element*},Element> takeWhile(Boolean taking(Element element)) => Iterating<{Element*},Return,Element>(this, shuffle(Return.takeWhile)(taking));
}

"Aspect or trait interface that provide iterating capability. "
shared interface IIterable<Return> satisfies IInvocable<Return> {
    "Adds a new step to the chain, by passing the result of the chain so far to a new function.
     The new function MUST accept the return type for the chain so far as its only parameter,
     and MUST return an Iterable type (i.o.w. return type for the new function should satisfy Iterable<Element,Absent>"
    see( `function package.iterate`, `function package.iterates`)
    shared default IIterating<NewReturn,Element,Absent> iterate<NewReturn, Element, Absent=Null>(NewReturn(Return) newFunc)
            given Absent satisfies Null
            given NewReturn satisfies Iterable<Element,Absent>
            => Iterating<NewReturn,Return,Element,Absent>(this, newFunc);
}

class Iterating<NewReturn, PrevReturn, Element, Absent=Null>(IInvocable<PrevReturn> prev, NewReturn(PrevReturn) func)
        extends InvocableChain<NewReturn,PrevReturn>(prev, func)
        satisfies IIterating<NewReturn,Element,Absent>
        given Absent satisfies Null
        given NewReturn satisfies Iterable<Element,Absent> {}

"Initial iterable step for a chain, whose results can be iterated."
shared IIterating<Return,Element,Absent> iterate<Return, Arguments, Element, Absent=Null>(Arguments arguments, Return(Arguments) func)
        given Absent satisfies Null
        given Return satisfies Iterable<Element,Absent>
        => object extends InvocableStart<Return,Arguments>(func, arguments)
        satisfies IIterating<Return,Element,Absent> {};

"Initial iterable step for a backward chain, whose results can be iterated.
  The only difference with [[iterate]] is that [[iterates]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared IIterating<Return,Element,Absent> iterates<Return, Arguments, Element, Absent=Null>(Arguments arguments, Return(*Arguments) func)
        given Absent satisfies Null
        given Return satisfies Iterable<Element,Absent>
        given Arguments satisfies Anything[]
        => object extends InvocableStartSpreading<Return,Arguments>(func, arguments)
        satisfies IIterating<Return,Element,Absent> {};
