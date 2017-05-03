import herd.chain {
    identityEach,
    lastParamToFirst
}

"Chain step that allows applying [[Iterable]] operation.
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
    [[IterableChain]]<Range<Integer>,Integer,Integer> bi = [[chainIterate]](10,foo);
    [[IterableChain]]<{Integer*},Integer,Integer> fi = bi.[[filter]](Integer.even).[[map]](Integer.successor);
    [[IterableChain]]<{Integer*},Integer,Integer> pr = fi.[[each]](print); // 'each' performs the function over each element, and returns the same
    pr.[[do]](); // Print all numbers in {3,5,7,9,11}, and returns this same sequence
 </pre>"
shared interface IterableChain<Return, Element, Absent=Null> satisfies IInvocable<Return>
        given Absent satisfies Null
        given Return satisfies Iterable<Element,Absent>
{
    shared Chain<Boolean> any(Boolean(Element) selecting) => Chaining<Boolean,Return>(this, shuffle(Return.any)(selecting));
    shared IterableChain<Iterable<Element,Absent>,Element> by(Integer step) => Iterating<Iterable<Element,Absent>,Return,Element>(this, shuffle(Return.by)(step));
    shared IterableChain<{Element|Other*},Element|Other> chain<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other)
            given OtherAbsent satisfies Null => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.chain<Other,OtherAbsent>)(other));
    shared IterableChain<Result[],Result> collect<Result>(Result(Element) collecting) => Iterating<Result[],Return,Result>(this, shuffle(Return.collect<Result>)(collecting));
    shared Chain<Boolean> contains(Object element) => Chaining<Boolean,Return>(this, shuffle(Return.contains)(element));
    shared Chain<Integer> count(Boolean(Element) selecting) => Chaining<Integer,Return>(this, shuffle(Return.count)(selecting));
    shared IterableChain<{Element&Object|Default*},Element&Object|Default> defaultNullElements<Default>(Default defaultValue)
            given Default satisfies Object => Iterating<{Element&Object|Default*},Return,Element&Object|Default>(this, shuffle(Return.defaultNullElements<Default>)(defaultValue));
    shared IterableChain<Return,Element> each(Anything(Element) operation) => Iterating<Return,Return,Element>(this, identityEach<Return,Element>(operation));
    shared Chain<Boolean> every(Boolean(Element) operation) => Chaining<Boolean,Return>(this, shuffle(Return.every)(operation));
    shared IterableChain<{Element*},Element> filter(Boolean(Element) operation) => Iterating<{Element*},Return,Element>(this, shuffle(Return.filter)(operation));
    shared Chain<Element?> find(Boolean(Element&Object) operation) => Chaining<Element?,Return>(this, shuffle(Return.find)(operation));
    shared Chain<Element?> findLast(Boolean(Element&Object) operation) => Chaining<Element?,Return>(this, shuffle(Return.findLast)(operation));
    shared IterableChain<{NewResult*},NewResult> flatMap<NewResult, OtherAbsent>(Iterable<NewResult,OtherAbsent>(Element) collecting)
            given OtherAbsent satisfies Null => Iterating<{NewResult*},Return,NewResult>(this, shuffle(Return.flatMap<NewResult,OtherAbsent>)(collecting));
    shared Chain<Result> fold<Result>(Result initial, Result(Result, Element) accumulating) => Chaining<Result,Return>(this, lastParamToFirst(Return.fold<Result>)(initial)(accumulating));
    shared IterableChain<{Element|Other*},Element|Other> follow<Other>(Other head) => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.follow<Other>)(head));
    shared IterableChain<Map<Element&Object,Integer>,Element&Object->Integer> frequencies() => Iterating<Map<Element&Object,Integer>,Return,Element&Object->Integer>(this, shuffle(Return.frequencies)());
    shared Chain<Element?> getFromFirst(Integer index) => Chaining<Element?,Return>(this, shuffle(Return.getFromFirst)(index));
    shared IterableChain<Map<Group,[Element+]>,Group->[Element+]> group<Group>(Group?(Element) grouping)
            given Group satisfies Object => Iterating<Map<Group,[Element+]>,Return,Group->[Element+]>(this, shuffle(Return.group<Group>)(grouping));
    shared IterableChain<Range<Integer>|[],Integer> indexes() => Iterating<Range<Integer>|[],Return,Integer>(this, shuffle(Return.indexes)());
    shared IterableChain<{Element|Other*},Element|Other> interpose<Other>(Other element, Integer step = 1) => Iterating<{Element|Other*},Return,Element|Other>(this, shuffle(Return.interpose<Other>)(element, step));
    shared Chain<Iterator<Element>> iterator() => Chaining<Iterator<Element>,Return>(this, shuffle(Return.iterator)());
    shared Chain<<Integer->Element&Object>?> locate(Boolean(Element&Object) selecting) => Chaining<<Integer->Element&Object>?,Return>(this, shuffle(Return.locate)(selecting));
    shared Chain<<Integer->Element&Object>?> locateLast(Boolean(Element&Object) selecting) => Chaining<<Integer->Element&Object>?,Return>(this, shuffle(Return.locateLast)(selecting));
    shared IterableChain<{<Integer->Element&Object>*},<Integer->Element&Object>> locations(Boolean(Element&Object) selecting)
            => Iterating<{<Integer->Element&Object>*},Return,<Integer->Element&Object>>(this, shuffle(Return.locations)(selecting));
    shared Chain<Boolean> longerThan(Integer length) => Chaining<Boolean,Return>(this, shuffle(Return.longerThan)(length));
    shared IterableChain<{NewReturn*},NewReturn> map<NewReturn>(NewReturn(Element) operation) => Iterating<{NewReturn*},Return,NewReturn>(this, shuffle(Return.map<NewReturn>)(operation));
    shared Chain<Element|Absent> max(Comparison(Element, Element) comparing) => Chaining<Element|Absent,Return>(this, shuffle(Return.max)(comparing));
    shared IterableChain<{Element&Type*},Element&Type> narrow<Type>() => Iterating<{Element&Type*},Return,Element&Type>(this, shuffle(Return.narrow<Type>)());
    shared IterableChain<Iterable<[Element+],Absent>,[Element+]> partition(Integer length) => Iterating<Iterable<[Element+],Absent>,Return,[Element+]>(this, shuffle(Return.partition)(length));
    shared IterableChain<Iterable<[Element, Other],Absent|OtherAbsent>,[Element, Other]> product<Other, OtherAbsent>(Iterable<Other,OtherAbsent> other)
            given OtherAbsent satisfies Null
            => Iterating<Iterable<[Element, Other],Absent|OtherAbsent>,Return,[Element, Other]>(this, shuffle(Return.product<Other,OtherAbsent>)(other));
    shared Chain<Result|Element|Absent> reduce<Result>(Result(Result|Element, Element) accumulating) => Chaining<Result|Element|Absent,Return>(this, shuffle(Return.reduce<Result>)(accumulating));
    shared IterableChain<{Element*},Element> repeat(Integer times) => Iterating<{Element*},Return,Element>(this, shuffle(Return.repeat)(times));
    shared IterableChain<{Result+},Result> scan<Result>(Result initial, Result(Result, Element) accumulating) => Iterating<{Result+},Return,Result>(this, lastParamToFirst(Return.scan<Result>)(initial)(accumulating));
    shared IterableChain<Element[],Element> select(Boolean selecting(Element element)) => Iterating<Element[],Return,Element>(this, shuffle(Return.select)(selecting));
    shared IterableChain<[Element+]|[]&Iterable<Element,Absent>,Element> sequence() => Iterating<[Element+]|[]&Iterable<Element,Absent>,Return,Element>(this, shuffle(Return.sequence)());
    shared Chain<Boolean> shorterThan(Integer length) => Chaining<Boolean,Return>(this, shuffle(Return.shorterThan)(length));
    shared IterableChain<{Element*},Element> skip(Integer skipping) => Iterating<{Element*},Return,Element>(this, shuffle(Return.skip)(skipping));
    shared IterableChain<{Element*},Element> skipWhile(Boolean skipping(Element element)) => Iterating<{Element*},Return,Element>(this, shuffle(Return.skipWhile)(skipping));
    shared IterableChain<Element[],Element> sort(Comparison comparing(Element x, Element y)) => Iterating<Element[],Return,Element>(this, shuffle(Return.sort)(comparing));
    shared Chain<Iterable<Result,Absent>(*Args)> spread<Result, Args>(Result(*Args) method(Element element))
            given Args satisfies Anything[]
            => Chaining<Iterable<Result,Absent>(*Args),Return>(this, shuffle(Return.spread<Result,Args>)(method));
    shared IterableChain<Map<Group,Result>,Group->Result> summarize<Group, Result>(Group? grouping(Element element), Result accumulating(Result? partial, Element element))
            given Group satisfies Object
            => Iterating<Map<Group,Result>,Return,Group->Result>(this, shuffle(Return.summarize<Group,Result>)(grouping, accumulating));
    shared IterableChain<Map<Element&Object,Result>,Element&Object->Result> tabulate<Result>(Result collecting(Element key))
            => Iterating<Map<Element&Object,Result>,Return,Element&Object->Result>(this, shuffle(Return.tabulate<Result>)(collecting));
    shared IterableChain<{Element*},Element> take(Integer taking) => Iterating<{Element*},Return,Element>(this, shuffle(Return.take)(taking));
    shared IterableChain<{Element*},Element> takeWhile(Boolean taking(Element element)) => Iterating<{Element*},Return,Element>(this, shuffle(Return.takeWhile)(taking));
}

"Aspect or trait interface that provide iterating capability. "
shared interface IIterable<Return> satisfies IInvocable<Return> {
    "Adds a new step to the chain, by passing the result of the chain so far to a new function.
     The new function MUST accept the return type for the chain so far as its only parameter,
     and MUST return an Iterable type (i.o.w. return type for the new function should satisfy Iterable<Element,Absent>"
    see (`function package.chainIterate`, `function package.iterate`)
    shared IterableChain<NewReturn,Element,Absent> iterate<NewReturn, Element, Absent=Null>(NewReturn(Return) newFunc)
            given Absent satisfies Null
            given NewReturn satisfies Iterable<Element,Absent>
            => Iterating<NewReturn,Return,Element,Absent>(this, newFunc);
}

class Iterating<NewReturn, PrevReturn, Element, Absent=Null>(IInvocable<PrevReturn> prev, NewReturn(PrevReturn) func)
        extends ChainStep<NewReturn,PrevReturn>(prev, func)
        satisfies IterableChain<NewReturn,Element,Absent>
        given Absent satisfies Null
        given NewReturn satisfies Iterable<Element,Absent> {}


"Initial iterable step for a chain, whose results can be iterated."
shared IterableChain<Arguments,Element,Absent> iterate<Arguments, Element, Absent=Null>(Arguments arguments)
        given Absent satisfies Null
        given Arguments satisfies Iterable<Element,Absent>
        => object extends ChainStart<Arguments>(arguments) satisfies IterableChain<Arguments,Element,Absent> {};

"Initial step for a chain, that chains arguments to an iterable function.
 It is just a shortcut for `[[chain]](arguments).[[iterate]](func)`"
shared IterableChain<Return,Element,Absent> chainIterate<Return, Arguments, Element, Absent=Null>(Arguments arguments, Return(Arguments) func)
        given Absent satisfies Null
        given Return satisfies Iterable<Element,Absent>
        => object extends ChainStartTo<Return,Arguments>(arguments, func)
        satisfies IterableChain<Return,Element,Absent> {};
