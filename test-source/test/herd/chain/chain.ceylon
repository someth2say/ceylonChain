import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chain,
    chainSpreadable,
    chainOptional,
    chainIterable
}

shared test void testChain() {
    // Chain start and parameter setting
    assertEquals(1, chain(cTtoT).with(0), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals(0, chain(cNtoT).with(null), "Invoking a ChainStart should directly invoke the method on the params");
}

shared test void testChainSpread() {
    // Chain start and parameter setting
    assertEquals([1, true], chainSpreadable(cTtoS).with(0), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([2, false], chainSpreadable(cTtoS).with(1), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([0, true], chainSpreadable(cNtoS).with(null), "Invoking a ChainStart Spread should directly invoke the method on the params");
}

shared test void testChainOptional() {

    assertEquals(1, chainOptional<Integer?, Integer?, Integer?>(cNtoT).with(0), "1 Optional Chaining callable should be able to start on callables accepting null");
    // This is tricky! As we are using a chainingOptional, cNtoT is not even called despite it accepts null! Hence, null is returned.
    assertEquals(0, chainOptional<Integer?, Integer?, Integer?>(cNtoT).with(null), "2 Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(1, chainOptional<Integer?, Integer?, Integer>(cTtoT).with(0), "3 Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(null, chainOptional<Integer?, Integer?, Integer>(cTtoT).with(null), "4 Optional Chaining callable should be able to start on callables NOT accepting null");
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
    assertEquals(2, chain(cTtoN).thenOptionally<Integer?,Integer?>(cNtoT).with(0), "1 Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(cTtoN).optionallyTo<Integer?,Integer?>(cNtoT).with(1), "2 Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(cNtoN).thenOptionally<Integer?,Integer?>(cNtoT).with(null), "3 Conditional composition should be able to compose on callables accepting null");

    // For callables NOT accepting null types
    assertEquals(2, chain(cTtoN).thenOptionally<Integer?,Integer>(cTtoT).with(0), "1 Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cTtoN).optionallyTo<Integer?,Integer>(cTtoT).with(1), "2 Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cNtoN).thenOptionally<Integer?,Integer>(cTtoT).with(null), "3 Conditional composition should be able to compose on callables not accepting null.");
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
    // Apply map operation
    assertTrue(iterableEquals({ 2, 0 }, chainIterable(cTtoI).map(Integer.successor).with(0)), "Iterable composition should be able to map iterable elements");
    //Following is equivalent, but maybe not that clear
    assertTrue(iterableEquals({ 2, 0 }, chain(cTtoI).to(shuffle(Iterable<Integer>.map<Integer>)(Integer.successor)).with(0)), "Iterable composition should be able to map iterable elements");

    // Apply fold operation
    assertEquals(6, (chainIterable(cTtoI).fold(2, (Integer a, Integer b) => a + b).with(2)), "Iterable composition should be able to fold iterable elements");

    variable Integer accum = 0;
    void addToLocal(Integer p) => accum += p;
    {Integer*} result = chainIterable(cTtoI).each(addToLocal).with(2);
    assertTrue(iterableEquals({3,1},result),"Iterable composition should be able to step each element of an iterable: ``result`` `");
    assertEquals(4,accum,"Iterable composition should be able to step each element of an iterable");

    // Collect
    assertEquals([2, 0], chainIterable(cTtoI).collect(identity<Integer>).with(1), "Iterable composition should be able to collect iterable elements");

}


