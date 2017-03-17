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
    assertEquals(1, chain(cTtoT, [0]).do(), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals(0, chain(cNtoT, [null]).do(), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals([2, true], chain(cStoS, [1, true]).do(), "Invoking a ChainStart with multiple parameters");
}

shared test void testChainSpread() {
    // Chain start and parameter setting
    assertEquals([1, true], chainSpreadable(cTtoS, [0]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([2, false], chainSpreadable(cTtoS, [1]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([0, true], chainSpreadable(cNtoS, [null]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
}

shared test void testChainOptional() {
    assertEquals(1, chainOptional(cNtoT, [0]).do(), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(0, chainOptional(cNtoT, [null]).do(), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(1, chainOptional(cTtoT, [0]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals([null], chainOptional(cTtoT, [null]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(["invalid"], chainOptional(cTtoT, ["invalid"]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals([0,"invalid"], chainOptional(cTtoT, [0,"invalid"]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
}

shared test void testSimpleComposition() {
    assertEquals(2, chain(cTtoT, [0]).\ithen(cTtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(1, chain(cNtoT, [null]).\ithen(cTtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(0, chain(cNtoN, [null]).to(cNtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals(null, chain(cTtoT, [0]).\ithen(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(3, chain(cTtoT, [1]).to(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals([2, false], chain(cTtoT, [0]).\ithen(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals([3, true], chain(cTtoT, [1]).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
}

shared test void testConditionalComposition() {
    // For callables accepting null types
    assertEquals(2, chain(cTtoN, [0]).thenOptionally(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(cTtoN, [1]).optionallyTo(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(cNtoN, [null]).thenOptionally(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");

    // For callables NOT accepting null types
    assertEquals(2, chain(cTtoN, [0]).thenOptionally(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cTtoN, [1]).optionallyTo(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cNtoN, [null]).thenOptionally(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
}

shared test void testSpreadingComposition() {
    //Starting from an spreadable
    assertEquals(2, chainSpreadable(cTtoS, [0]).thenSpreadTo(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, chainSpreadable(cTtoS, [1]).spreadTo(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, chainSpreadable(cNtoS, [null]).thenSpreadTo(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    //Continuing from a non-spreadable...
    assertEquals(1, chain(cTtoT, [0]).thenSpreadable(cTtoS).thenSpreadTo(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(4, chain(cTtoT, [1]).thenSpreadable(cTtoS).spreadTo(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, chain(cNtoT, [null]).thenSpreadable(cTtoS).thenSpreadTo(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    // Optionally spreading
    //    assertEquals(2, chainSpreadable(cTtoS).thenOptionalySpreadTo(cTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    //    assertEquals(1, chainSpreadable(cTtoS).thenOptionalySpreadTo(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");

    // Spreading to an spreadable
    assertEquals([2, true], chainSpreadable(cTtoS, [0]).thenSpreadToSpreadable(cStoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], chainSpreadable(cTtoS, [1]).spreadToSpreadable(cStoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], chainSpreadable(cNtoS, [null]).thenSpreadToSpreadable(cStoS).do(), "Spreadable composition should be able to compose on callables accepting null");
}

shared test void testIterableComposition() {
    // Apply map operation
    assertTrue(iterableEquals({ 2, 0 }, chainIterable(cTtoI, [0]).map(Integer.successor).do()), "Iterable composition should be able to map iterable elements");
    //Following is equivalent, but maybe not that clear
    assertTrue(iterableEquals({ 2, 0 }, chain(cTtoI, [0]).to(shuffle(Iterable<Integer>.map<Integer>)(Integer.successor)).do()), "Iterable composition should be able to map iterable elements");

    // Apply fold operation
    Integer sum2(Integer a, Integer b) => a + b;
    assertEquals(6, (chainIterable(cTtoI, [2]).fold(2, sum2).do()), "Iterable composition should be able to fold iterable elements");

    variable Integer accum = 0;
    void addToLocal(Integer p) => accum += p;
    {Integer*} result = chainIterable(cTtoI, [2]).each(addToLocal).do();
    assertTrue(iterableEquals({3,1},result),"Iterable composition should be able to step each element of an iterable");
    assertEquals(4, accum, "Iterable composition should be able to step each element of an iterable");

    // Collect
    assertEquals([2, 0], chainIterable(cTtoI, [1]).collect(identity<Integer>).do(), "Iterable composition should be able to collect iterable elements");

}
