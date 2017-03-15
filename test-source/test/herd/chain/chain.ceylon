

/*
 Test callables should hancle three types:
 T -> Unbounded type (i.e. Integer)
 N -> Nullable type (i.e. Integer?)
 S -> Spreadable type (i.e. *Integer)
 I -> Iterable type (i.e. {Integer*}"
*/
Integer(Integer) cTtoT = Integer.successor;
Integer?(Integer) cTtoN = (Integer int) => if (int.even) then int.successor else null;
[Integer, Boolean](Integer) cTtoS = (Integer int) => [int.successor, int.even];

Integer(Integer?) cNtoT = (Integer? int) => if (exists int) then int.successor else 0;
Integer?(Integer?) cNtoN = (Integer? int) => if (exists int) then int.successor else null;
[Integer, Boolean](Integer?) cNtoS = (Integer? int) => if (exists int) then [int.successor, int.even] else [0, true];

Integer(Integer, Boolean) cStoT = (Integer int, Boolean b) => if (b) then int.successor else int.predecessor;
Integer?(Integer, Boolean) cStoN = (Integer int, Boolean b) => if (b) then int.successor else null;

[Integer, Boolean](Integer, Boolean) cStoS = (Integer int, Boolean b) => if (b) then [int.successor, b] else [int.successor, b];

{Integer*}(Integer) cTtoI = (Integer int) => { int.successor, int.predecessor };

shared test void testChain() {
    // Chain start and parameter setting
    assertEquals(1, chain(cTtoT).with(0), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals(0, chain(cNtoT).with(null), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals(2, chain2(cTtoT, cTtoT).with(0), "Invoking a ChainStart with two functions");
    assertEquals(3, chain3(cTtoT, cTtoT, cTtoT).with(0), "Invoking a ChainStart with three functions");
}

shared test void testChainSpread() {
    // Chain start and parameter setting
    assertEquals([1, true], chainSpreadable(cTtoS).with(0), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([2, false], chainSpreadable(cTtoS).with(1), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([0, true], chainSpreadable(cNtoS).with(null), "Invoking a ChainStart Spread should directly invoke the method on the params");
}

shared test void testChainOptional() {

    assertEquals(1, chainOptional(cNtoT).with(0), "Optional Chaining callable should be able to start on callables accepting null");
    // This is tricky! As we are using a chainingOptional, cNtoT is not even called despite it accepts null! Hence, null is returned.
    assertEquals(null, chainOptional(cNtoT).with(null), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(1, chainOptional(cTtoT).with(0), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(null, chainOptional(cTtoT).with(null), "Optional Chaining callable should be able to start on callables NOT accepting null");
}

shared test void testSimpleComposition() {
    assertEquals(2, chain(cTtoT).\ithen(cTtoT).with(0), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(1, chain(cNtoT).\ithen(cTtoT).with(null), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(0, chain(cNtoN).to(cNtoT).with(null), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals(null, chain(cTtoT).\ithen(cTtoN).with(0), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(3, chain(cTtoT).to(cTtoN).with(1), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals([2, false], chain(cTtoT).\ithen(cTtoS).with(0), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals([3, true], chain(cTtoT).to(cTtoS).with(1), "Chained callables should be equivalent to invonking those callables in the opposing order.");
}

shared test void testConditionalComposition() {

    // For callables accepting null types
    assertEquals(2, chain(cTtoN).thenOptionally(cNtoT).with(0), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(null, chain(cTtoN).optionallyTo(cNtoT).with(1), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(null, chain(cNtoN).thenOptionally(cNtoT).with(null), "Conditional composition should be able to compose on callables accepting null");

    // For callables NOT accepting null types
    assertEquals(2, chain(cTtoN).thenOptionally(cTtoT).with(0), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cTtoN).optionallyTo(cTtoT).with(1), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cNtoN).thenOptionally(cTtoT).with(null), "Conditional composition should be able to compose on callables not accepting null.");
}

shared test void testSpreadingComposition() {
    //Starting from an spreadable
    assertEquals(2, chainSpreadable(cTtoS).thenSpreadTo(cStoT).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, chainSpreadable(cTtoS).spreadTo(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, chainSpreadable(cNtoS).thenSpreadTo(cStoT).with(null), "Spreadable composition should be able to compose on callables accepting null");

    //Continuing from a non-spreadable...
    assertEquals(1, chain(cTtoT).thenSpreadable(cTtoS).thenSpreadTo(cStoT).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(4, chain(cTtoT).thenSpreadable(cTtoS).spreadTo(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, chain(cNtoT).thenSpreadable(cTtoS).thenSpreadTo(cStoT).with(null), "Spreadable composition should be able to compose on callables accepting null");

    // Optionally spreading
    //    assertEquals(2, chainSpreadable(cTtoS).thenOptionalySpreadTo(cTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    //    assertEquals(1, chainSpreadable(cTtoS).thenOptionalySpreadTo(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");

    // Spreading to an spreadable
    assertEquals([2, true], chainSpreadable(cTtoS).thenSpreadToSpreadable(cStoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], chainSpreadable(cTtoS).spreadToSpreadable(cStoS).with(1), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], chainSpreadable(cNtoS).thenSpreadToSpreadable(cStoS).with(null), "Spreadable composition should be able to compose on callables accepting null");
}


Boolean optionalEquals(Anything first, Anything second) => if (exists first, exists second) then first.equals(second) else (!first exists&& !second exists);
Boolean iterableEquals({Anything*} it1, {Anything*} it2) => it1.empty && it2.empty || it1.size == it2.size &&optionalEquals(it1.first, it2.first) &&iterableEquals(it1.rest, it2.rest);

shared test void testIterableComposition() {
    // Apply stream operations
    assertTrue(iterableEquals({ 2, 0 }, chainIterable(cTtoI).map(Integer.successor).with(0)), "Iterable composition should be able to map iterable elements");
    //Following is equivalent, but maybe not that usefull
    assertTrue(iterableEquals({ 2, 0 }, chain(cTtoI).to(swap(Iterable<Integer>.map<Integer>)(Integer.successor)).with(0)), "Iterable composition should be able to map iterable elements");
}



