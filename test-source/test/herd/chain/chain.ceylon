import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chain,
    spread,
    trying,
    iterate
}

shared test void testChain() {
    // Chain start and parameter setting
    assertEquals(1, chain(cTtoT, [0]).do(), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals(0, chain(cNtoT, [null]).do(), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals([2, true], chain(cStoS, [1, true]).do(), "Invoking a ChainStart with multiple parameters");
}

shared test void testChainSpread() {
    // Chain start and parameter setting
    assertEquals([1, true], spread(cTtoS, [0]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([2, false], spread(cTtoS, [1]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([0, true], spread(cNtoS, [null]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
}

shared test void testTrying() {
    assertEquals(1, \itry(cNtoT, [0]).do(), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(0, \itry(cNtoT, [null]).do(), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(1, \itry(cTtoT, [0]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals([null], \itry(cTtoT, [null]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(["invalid"], \itry(cTtoT, ["invalid"]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals([0,"invalid"], \itry(cTtoT, [0,"invalid"]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
}

shared test void testChainTo() {
    assertEquals(2, chain(cTtoT, [0]).to(cTtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(1, chain(cNtoT, [null]).to(cTtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(0, chain(cNtoN, [null]).to(cNtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals(null, chain(cTtoT, [0]).to(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(3, chain(cTtoT, [1]).to(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals([2, false], chain(cTtoT, [0]).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals([3, true], chain(cTtoT, [1]).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
}

shared test void testChainTry() {
    // For callables accepting null types
    assertEquals(2, chain(cTtoN, [0]).\itry(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(cTtoN, [1]).\itry(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(cNtoN, [null]).\itry(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");

    // For callables NOT accepting null types
    assertEquals(2, chain(cTtoN, [0]).\itry(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cTtoN, [1]).\itry(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cNtoN, [null]).\itry(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
}

shared test void testSpread() {
    //Starting from an spreadable
    assertEquals(2, spread(cTtoS, [0]).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(cTtoS, [1]).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(cNtoS, [null]).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    //Continuing from a non-spreadable...
    assertEquals(1, chain(cTtoT, [0]).spread(cTtoS).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(4, chain(cTtoT, [1]).spread(cTtoS).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, chain(cNtoT, [null]).spread(cTtoS).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    // Optionally spreading
    //    assertEquals(2, spread(cTtoS).thenOptionalyto(cTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    //    assertEquals(1, spread(cTtoS).thenOptionalyto(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");

    // Spreading to an spreadable
    assertEquals([2, true], spread(cTtoS, [0]).keepSpreading(cStoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], spread(cTtoS, [1]).keepSpreading(cStoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], spread(cNtoS, [null]).keepSpreading(cStoS).do(), "Spreadable composition should be able to compose on callables accepting null");
}

shared test void testIterate() {
    assertTrue(iterableEquals({ 3, 1 },chain(cTtoT,[1]).iterate(cTtoI).do()),"Iterable composition after a chain");
    // Apply map operation
    assertTrue(iterableEquals({ 2, 0 }, iterate(cTtoI, [0]).map(Integer.successor).do()), "Iterable composition should be able to map iterable elements");
    //Following is equivalent, but maybe not that clear
    //assertTrue(iterableEquals({ 2, 0 }, chain(cTtoI, [0]).to(shuffle(Iterable<Integer>.map<Integer>)(Integer.successor)).do()), "Iterable composition should be able to map iterable elements");

    // Apply fold operation

    assertEquals(6, (iterate(cTtoI, [2]).fold(2, (Integer a, Integer b) => a + b).do()), "Iterable composition should be able to fold iterable elements");

    variable Integer accum = 0;
    {Integer*} result = iterate(cTtoI, [2]).each((Integer p) => accum += p).do();
    assertTrue(iterableEquals({3,1},result),"Iterable composition should be able to step each element of an iterable");
    assertEquals(4, accum, "Iterable composition should be able to step each element of an iterable");

    // Collect
    assertEquals([2, 0], iterate(cTtoI, [1]).collect(identity<Integer>).do(), "Iterable composition should be able to collect iterable elements");

}
