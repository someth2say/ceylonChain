import herd.chain {
    identityEach,
    lastParamToFirst
}

"Chain step that allows applying Iterable operation.
 <pre>
    value iterable = methodReturningAnIterable(initialValue);
    value mappedIterable = iterable.map(mappingMethod);
    value next = methodWorkingOnIterable(mappedIterable);
    ...
 </pre>
 IOW, provide the ability to perform same operations that user can perform onto an iterable.

 Iterating chain steps require a function whose return type can be iterated (i.o.w, satisfies {Anything*}).

 Example:
 <pre>
    Range<Integer> foo(Integer i) => (1..i); // Note Range<...> satisfies Iterable
    IterableStep<Range<Integer>,Integer,Integer> bi = chainIterate(10,foo);
    IterableStep<{Integer*},Integer,Integer> fi = bi.filter(Integer.even).map(Integer.successor);
    IterableStep<{Integer*},Integer,Integer> pr = fi.each(print); // 'each' performs the function over each element, and returns the same
    pr.do(); // Print all numbers in {3,5,7,9,11}, and returns this same sequence
 </pre>"
shared interface IterableStep<Return, Element, Absent=Null> satisfies Invocable<Return>
        given Absent satisfies Null
        given Return satisfies Iterable<Element,Absent>
{
    "Emulates Iterable.any"
    see (`function Iterable.any`)
    shared Chain<Boolean> any(Boolean(Element) selecting)
            => Chaining<Boolean,Return>(this, shuffle(Return.any)(selecting));

    "Emulates Iterable.by"
    see (`function Iterable.by`)
    shared IterableStep<Iterable<Element,Absent>,Element> by(Integer step)
            => Iterating<Iterable<Element,Absent>,Return,Element>(this, shuffle(Return.by)(step));

    "Emulates Iterable.chain"
    see (`function Iterable.chain`)
    shared IterableStep<{Element|Other*},Element|Other> chain<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other)
            given OtherAbsent satisfies Null
            => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.chain<Other,OtherAbsent>)(other));

    "Emulates Iterable.collect"
    see (`function Iterable.collect`)
    shared IterableStep<Result[],Result> collect<Result>(Result(Element) collecting)
            => Iterating<Result[],Return,Result>(this, shuffle(Return.collect<Result>)(collecting));

    "Emulates Iterable.contains"
    see (`function Iterable.contains`)
    shared Chain<Boolean> contains(Object element)
            => Chaining<Boolean,Return>(this, shuffle(Return.contains)(element));

    "Emulates Iterable.count"
    see (`function Iterable.count`)
    shared Chain<Integer> count(Boolean(Element) selecting)
            => Chaining<Integer,Return>(this, shuffle(Return.count)(selecting));

    "Emulates Iterable.defaultNullElements"
    see (`function Iterable.defaultNullElements`)
    shared IterableStep<{Element&Object|Default*},Element&Object|Default> defaultNullElements<Default>(Default defaultValue)
            given Default satisfies Object
            => Iterating<{Element&Object|Default*},Return,Element&Object|Default>(this, shuffle(Return.defaultNullElements<Default>)(defaultValue));

    "Emulates Iterable.each"
    see (`function Iterable.each`)
    shared IterableStep<Return,Element> each(Anything(Element) operation)
            => Iterating<Return,Return,Element>(this, identityEach<Return,Element>(operation));

    "Emulates Iterable.every"
    see (`function Iterable.every`)
    shared Chain<Boolean> every(Boolean(Element) operation)
            => Chaining<Boolean,Return>(this, shuffle(Return.every)(operation));

    "Emulates Iterable.filter"
    see (`function Iterable.filter`)
    shared IterableStep<{Element*},Element> filter(Boolean(Element) operation)
            => Iterating<{Element*},Return,Element>(this, shuffle(Return.filter)(operation));

    "Emulates Iterable.find"
    see (`function Iterable.find`)
    shared Chain<Element?> find(Boolean(Element&Object) operation)
            => Chaining<Element?,Return>(this, shuffle(Return.find)(operation));

    "Emulates Iterable.findLast"
    see (`function Iterable.findLast`)
    shared Chain<Element?> findLast(Boolean(Element&Object) operation)
            => Chaining<Element?,Return>(this, shuffle(Return.findLast)(operation));

    "Emulates Iterable.flatMap"
    see (`function Iterable.flatMap`)
    shared IterableStep<{NewResult*},NewResult> flatMap<NewResult, OtherAbsent>(Iterable<NewResult,OtherAbsent>(Element) collecting)
            given OtherAbsent satisfies Null
            => Iterating<{NewResult*},Return,NewResult>(this, shuffle(Return.flatMap<NewResult,OtherAbsent>)(collecting));

    "Emulates Iterable.fold"
    see (`function Iterable.fold`)
    shared Chain<Result> fold<Result>(Result initial, Result(Result, Element) accumulating)
            => Chaining<Result,Return>(this, lastParamToFirst(Return.fold<Result>)(initial)(accumulating));

    "Emulates Iterable.follow"
    see (`function Iterable.follow`)
    shared IterableStep<{Element|Other*},Element|Other> follow<Other>(Other head)
            => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.follow<Other>)(head));

    "Emulates Iterable.frequencies"
    see (`function Iterable.frequencies`)
    shared IterableStep<Map<Element&Object,Integer>,Element&Object->Integer> frequencies()
            => Iterating<Map<Element&Object,Integer>,Return,Element&Object->Integer>(this, shuffle(Return.frequencies)());

    "Emulates Iterable.getFromFirst"
    see (`function Iterable.getFromFirst`)
    shared Chain<Element?> getFromFirst(Integer index)
            => Chaining<Element?,Return>(this, shuffle(Return.getFromFirst)(index));

    "Emulates Iterable.group"
    see (`function Iterable.group`)
    shared IterableStep<Map<Group,[Element+]>,Group->[Element+]> group<Group>(Group?(Element) grouping)
            given Group satisfies Object
            => Iterating<Map<Group,[Element+]>,Return,Group->[Element+]>(this, shuffle(Return.group<Group>)(grouping));

    "Emulates Iterable.indexes"
    see (`function Iterable.indexes`)
    shared IterableStep<Range<Integer>|[],Integer> indexes()
            => Iterating<Range<Integer>|[],Return,Integer>(this, shuffle(Return.indexes)());

    "Emulates Iterable.interpose"
    see (`function Iterable.interpose`)
    shared IterableStep<{Element|Other*},Element|Other> interpose<Other>(Other element, Integer step = 1)
            => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.interpose<Other>)(element, step));

    "Emulates Iterable.iterator"
    see (`function Iterable.iterator`)
    shared Chain<Iterator<Element>> iterator()
            => Chaining<Iterator<Element>,Return>(this, shuffle(Return.iterator)());

    "Emulates Iterable.locate"
    see (`function Iterable.locate`)
    shared Chain<<Integer->Element&Object>?> locate(Boolean(Element&Object) selecting)
            => Chaining<<Integer->Element&Object>?,Return>(this, shuffle(Return.locate)(selecting));

    "Emulates Iterable.locateLast"
    see (`function Iterable.locateLast`)
    shared Chain<<Integer->Element&Object>?> locateLast(Boolean(Element&Object) selecting)
            => Chaining<<Integer->Element&Object>?,Return>(this, shuffle(Return.locateLast)(selecting));

    "Emulates Iterable.locations"
    see (`function Iterable.locations`)
    shared IterableStep<{<Integer->Element&Object>*},<Integer->Element&Object>> locations(Boolean(Element&Object) selecting)
            => Iterating<{<Integer->Element&Object>*},Return,<Integer->Element&Object>>(this, shuffle(Return.locations)(selecting));

    "Emulates Iterable.longerThan"
    see (`function Iterable.longerThan`)
    shared Chain<Boolean> longerThan(Integer length)
            => Chaining<Boolean,Return>(this, shuffle(Return.longerThan)(length));

    "Emulates Iterable.map"
    see (`function Iterable.map`)
    shared IterableStep<{NewReturn*},NewReturn> map<NewReturn>(NewReturn(Element) operation)
            => Iterating<{NewReturn*},Return,NewReturn>(this, shuffle(Return.map<NewReturn>)(operation));

    "Emulates Iterable.max"
    see (`function Iterable.max`)
    shared Chain<Element|Absent> max(Comparison(Element, Element) comparing)
            => Chaining<Element|Absent,Return>(this, shuffle(Return.max)(comparing));

    "Emulates Iterable.narrow"
    see (`function Iterable.narrow`)
    shared IterableStep<{Element&Type*},Element&Type> narrow<Type>()
            => Iterating<{Element&Type*},Return,Element&Type>(this, shuffle(Return.narrow<Type>)());

    "Emulates Iterable.partition"
    see (`function Iterable.partition`)
    shared IterableStep<Iterable<[Element+],Absent>,[Element+]> partition(Integer length)
            => Iterating<Iterable<[Element+],Absent>,Return,[Element+]>(this, shuffle(Return.partition)(length));

    "Emulates Iterable.product"
    see (`function Iterable.product`)
    shared IterableStep<Iterable<[Element, Other],Absent|OtherAbsent>,[Element, Other]> product<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other)
            given OtherAbsent satisfies Null
            => Iterating<Iterable<[Element, Other],Absent|OtherAbsent>,Return,[Element, Other]>(this, shuffle(Return.product<Other,OtherAbsent>)(other));

    "Emulates Iterable.reduce"
    see (`function Iterable.reduce`)
    shared Chain<Result|Element|Absent> reduce<Result>(Result(Result|Element, Element) accumulating)
            => Chaining<Result|Element|Absent,Return>(this, shuffle(Return.reduce<Result>)(accumulating));

    "Emulates Iterable.repeat"
    see (`function Iterable.repeat`)
    shared IterableStep<{Element*},Element> repeat(Integer times)
            => Iterating<{Element*},Return,Element>(this, shuffle(Return.repeat)(times));

    "Emulates Iterable.scan"
    see (`function Iterable.scan`)
    shared IterableStep<{Result+},Result> scan<Result>(Result initial, Result(Result, Element) accumulating)
            => Iterating<{Result+},Return,Result>(this, lastParamToFirst(Return.scan<Result>)(initial)(accumulating));

    "Emulates Iterable.select"
    see (`function Iterable.select`)
    shared IterableStep<Element[],Element> select(Boolean selecting(Element element))
            => Iterating<Element[],Return,Element>(this, shuffle(Return.select)(selecting));

    "Emulates Iterable.sequence"
    see (`function Iterable.sequence`)
    shared IterableStep<[Element+]|[]&Iterable<Element,Absent>,Element> sequence()
            => Iterating<[Element+]|[]&Iterable<Element,Absent>,Return,Element>(this, shuffle(Return.sequence)());

    "Emulates Iterable.shorterThan"
    see (`function Iterable.shorterThan`)
    shared Chain<Boolean> shorterThan(Integer length)
            => Chaining<Boolean,Return>(this, shuffle(Return.shorterThan)(length));

    "Emulates Iterable.skip"
    see (`function Iterable.skip`)
    shared IterableStep<{Element*},Element> skip(Integer skipping)
            => Iterating<{Element*},Return,Element>(this, shuffle(Return.skip)(skipping));

    "Emulates Iterable.skipWhile"
    see (`function Iterable.skipWhile`)
    shared IterableStep<{Element*},Element> skipWhile(Boolean skipping(Element element))
            => Iterating<{Element*},Return,Element>(this, shuffle(Return.skipWhile)(skipping));

    "Emulates Iterable.sort"
    see (`function Iterable.sort`)
    shared IterableStep<Element[],Element> sort(Comparison comparing(Element x, Element y))
            => Iterating<Element[],Return,Element>(this, shuffle(Return.sort)(comparing));

    "Emulates Iterable.spread"
    see (`function Iterable.spread`)
    shared Chain<Iterable<Result,Absent>(*Args)> spread<Result, Args>(Result(*Args) method(Element element))
            given Args satisfies Anything[]
            => Chaining<Iterable<Result,Absent>(*Args),Return>(this, shuffle(Return.spread<Result,Args>)(method));

    "Emulates Iterable.summarize"
    see (`function Iterable.summarize`)
    shared IterableStep<Map<Group,Result>,Group->Result> summarize<Group, Result>(Group? grouping(Element element), Result accumulating(Result? partial, Element element))
            given Group satisfies Object
            => Iterating<Map<Group,Result>,Return,Group->Result>(this, shuffle(Return.summarize<Group,Result>)(grouping, accumulating));

    "Emulates Iterable.tabulate"
    see (`function Iterable.tabulate`)
    shared IterableStep<Map<Element&Object,Result>,Element&Object->Result> tabulate<Result>(Result collecting(Element key))
            => Iterating<Map<Element&Object,Result>,Return,Element&Object->Result>(this, shuffle(Return.tabulate<Result>)(collecting));

    "Emulates Iterable.take"
    see (`function Iterable.take`)
    shared IterableStep<{Element*},Element> take(Integer taking)
            => Iterating<{Element*},Return,Element>(this, shuffle(Return.take)(taking));

    "Emulates Iterable.takeWhile"
    see (`function Iterable.takeWhile`)
    shared IterableStep<{Element*},Element> takeWhile(Boolean taking(Element element))
            => Iterating<{Element*},Return,Element>(this, shuffle(Return.takeWhile)(taking));
}

"Aspect or trait interface that provide iterating capability. "
shared interface IterableChain<Return> satisfies Invocable<Return> {
    "Adds a new step to the chain, by passing the result of the chain so far to a new function.
     The new function MUST accept the return type for the chain so far as its only parameter,
     and MUST return an Iterable type (i.o.w. return type for the new function should satisfy Iterable<Element,Absent>"
    see (`function package.chainIterate`, `function package.iterate`)
    shared IterableStep<NewReturn,Element,Absent> iterate<NewReturn, Element, Absent=Null>(NewReturn(Return) newFunc)
            given Absent satisfies Null
            given NewReturn satisfies Iterable<Element,Absent>
            => Iterating<NewReturn,Return,Element,Absent>(this, newFunc);
}

class Iterating<NewReturn, PrevReturn, Element, Absent=Null>(Invocable<PrevReturn> prev, NewReturn(PrevReturn) func)
        extends ChainingInvocable<NewReturn,PrevReturn>(prev, func)
        satisfies IterableStep<NewReturn,Element,Absent>
        given Absent satisfies Null
        given NewReturn satisfies Iterable<Element,Absent> {}


"Initial iterable step for a chain, whose results can be iterated."
shared IterableStep<Arguments,Element,Absent> iterate<Arguments, Element, Absent=Null>(Arguments arguments)
        given Absent satisfies Null
        given Arguments satisfies Iterable<Element,Absent>
        => object extends IdentityInvocable<Arguments>(arguments) satisfies IterableStep<Arguments,Element,Absent> {};

"Initial step for a chain, that chains arguments to an iterable function.
 It is just a shortcut for `chain(arguments).iterate(func)`"
shared IterableStep<Return,Element,Absent> chainIterate<Return, Arguments, Element, Absent=Null>(Arguments arguments, Return(Arguments) func)
        given Absent satisfies Null
        given Return satisfies Iterable<Element,Absent>
        => object extends FunctionInvocable<Return,Arguments>(arguments, func)
        satisfies IterableStep<Return,Element,Absent> {};
