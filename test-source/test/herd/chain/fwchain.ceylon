import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    fwchain,
    fwChainSpreadable, fwChainOptional

}

shared test void testFwChain() {
    // Chain start and parameter setting
    assertEquals(1, fwchain(cTtoT, [0]).do(), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals(0, fwchain(cNtoT, [null]).do(), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals([2, true], fwchain(cStoS, [1, true]).do(), "Invoking a ChainStart with multiple parameters");
}

shared test void testFwChainSpread() {
    // Chain start and parameter setting
    assertEquals([1, true], fwChainSpreadable(cTtoS, [0]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([2, false], fwChainSpreadable(cTtoS, [1]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([0, true], fwChainSpreadable(cNtoS, [null]).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
}

shared test void testFwChainOptional() {
    assertEquals(1, fwChainOptional(cNtoT,[0]).do(), "Optional Chaining callable should be able to start on callables accepting null");
    // This is tricky! As we are using a chainingOptional, cNtoT is not even called despite it accepts null! Hence, null is returned.
    assertEquals(0, fwChainOptional(cNtoT,[null]).do(), "Optional Chaining callable should be able to start on callables accepting null ----");
    assertEquals(1, fwChainOptional(cTtoT,[0]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(null, fwChainOptional(cTtoT,[null]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
}

shared test void testFwSimpleComposition() {
    assertEquals(2, fwchain(cTtoT, [0]).\ithen(cTtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(1, fwchain(cNtoT, [null]).\ithen(cTtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(0, fwchain(cNtoN, [null]).to(cNtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals(null, fwchain(cTtoT, [0]).\ithen(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(3, fwchain(cTtoT, [1]).to(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals([2, false], fwchain(cTtoT, [0]).\ithen(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals([3, true], fwchain(cTtoT, [1]).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
}
//
//shared test void testConditionalComposition() {
//
//    // For callables accepting null types
//    assertEquals(2, chain(cTtoN).thenOptionally(cNtoT).with(0), "Conditional composition should be able to compose on callables accepting null");
//    assertEquals(null, chain(cTtoN).optionallyTo(cNtoT).with(1), "Conditional composition should be able to compose on callables accepting null");
//    assertEquals(null, chain(cNtoN).thenOptionally(cNtoT).with(null), "Conditional composition should be able to compose on callables accepting null");
//
//    // For callables NOT accepting null types
//    assertEquals(2, chain(cTtoN).thenOptionally(cTtoT).with(0), "Conditional composition should be able to compose on callables not accepting null.");
//    assertEquals(null, chain(cTtoN).optionallyTo(cTtoT).with(1), "Conditional composition should be able to compose on callables not accepting null.");
//    assertEquals(null, chain(cNtoN).thenOptionally(cTtoT).with(null), "Conditional composition should be able to compose on callables not accepting null.");
//}
//
//shared test void testSpreadingComposition() {
//    //Starting from an spreadable
//    assertEquals(2, chainSpreadable(cTtoS).thenSpreadTo(cStoT).with(0), "Spreadable composition should be able to compose on callables accepting null");
//    assertEquals(1, chainSpreadable(cTtoS).spreadTo(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");
//    assertEquals(1, chainSpreadable(cNtoS).thenSpreadTo(cStoT).with(null), "Spreadable composition should be able to compose on callables accepting null");
//
//    //Continuing from a non-spreadable...
//    assertEquals(1, chain(cTtoT).thenSpreadable(cTtoS).thenSpreadTo(cStoT).with(0), "Spreadable composition should be able to compose on callables accepting null");
//    assertEquals(4, chain(cTtoT).thenSpreadable(cTtoS).spreadTo(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");
//    assertEquals(2, chain(cNtoT).thenSpreadable(cTtoS).thenSpreadTo(cStoT).with(null), "Spreadable composition should be able to compose on callables accepting null");
//
//    // Optionally spreading
//    //    assertEquals(2, chainSpreadable(cTtoS).thenOptionalySpreadTo(cTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
//    //    assertEquals(1, chainSpreadable(cTtoS).thenOptionalySpreadTo(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");
//
//    // Spreading to an spreadable
//    assertEquals([2, true], chainSpreadable(cTtoS).thenSpreadToSpreadable(cStoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
//    assertEquals([3, false], chainSpreadable(cTtoS).spreadToSpreadable(cStoS).with(1), "Spreadable composition should be able to compose on callables accepting null");
//    assertEquals([1, true], chainSpreadable(cNtoS).thenSpreadToSpreadable(cStoS).with(null), "Spreadable composition should be able to compose on callables accepting null");
//}
//
//
////Boolean optionalEquals(Anything first, Anything second) => if (exists first, exists second) then first.equals(second) else (!first exists&& !second exists);
////Boolean iterableEquals({Anything*} it1, {Anything*} it2) => it1.empty && it2.empty || it1.size == it2.size &&optionalEquals(it1.first, it2.first) &&iterableEquals(it1.rest, it2.rest);
//
//Integer sum2(Integer a, Integer b) => a + b;
//
//
//shared test void testIterableComposition() {
//    // Apply map operation
//    //assertTrue(iterableEquals({ 2, 0 }, chainIterable(cTtoI).map(Integer.successor).with(0)), "Iterable composition should be able to map iterable elements");
//    //Following is equivalent, but maybe not that clear
//    //assertTrue(iterableEquals({ 2, 0 }, chain(cTtoI).to(shuffle(Iterable<Integer>.map<Integer>)(Integer.successor)).with(0)), "Iterable composition should be able to map iterable elements");
//
//    // Apply fold operation
//    assertEquals(6, (chainIterable(cTtoI).fold(2, sum2).with(2)), "Iterable composition should be able to fold iterable elements");
//
//    variable Integer accum = 0;
//    void addToLocal(Integer p) => accum += p;
//    {Integer*} result = chainIterable(cTtoI).each(addToLocal).with(2);
////    assertTrue({1,3},result,"Iterable composition should be able to step each element of an iterable");
//    assertEquals(4,accum,"Iterable composition should be able to step each element of an iterable");
//
//    // Collect
//    assertEquals([2, 0], chainIterable(cTtoI).collect(identity<Integer>).with(1), "Iterable composition should be able to collect iterable elements");
//
//}
//
//
//
