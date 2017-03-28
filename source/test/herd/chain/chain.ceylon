import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain,
    chains,
    bwchain
}

shared test void testChain() {
    // Chain start and parameter setting
    assertEquals(1, chain(cTtoT, 0).do(), "Basic chain");
    assertEquals(0, chain(cNtoT, null).do(), "Basic chain, null params");
    assertEquals(null, chain(cTtoN, 1).do(), "Basic chain, null params, null return");
    assertEquals([2, true], chain(cStoS, [1, true]).do(), "Basic chain, tuple params, tuple return");
    assertEquals([1, true], chain(cTtoS, 0).do(), "Basic chain, tuple return ");
    assertEquals([0, true], chain(cNtoS, null).do(), "Basic chain, null params, tuple return");
}

shared test void testBwChain() {
    // Chain start and parameter setting
    assertEquals(2, bwchain(cTtoT).with(1), "Basic Fw chain");
    assertEquals(0, bwchain(cNtoT).with(null), "Basic Fw chain, null params");
    assertEquals(null, bwchain(cTtoN).with(1), "Basic Fw chain, null params, null return");
}

shared test void testChainSpread() {
    assertEquals(2, chains(cTTtoT, [1, true]).do(), "Basic chain, spreading params");
}

shared test void testChainTo() {
    assertEquals(2, chain(cTtoT, 0).to(cTtoT).do(), "Basic chain to basic chain");
    assertEquals(1, chain(cNtoT, null).to(cTtoT).do(), "Basic chain to basic chain, null params");
    assertEquals(0, chain(cNtoN, null).to(cNtoT).do(), "Basic chain to basic chain, null params, null return");

    assertEquals(null, chain(cTtoT, 0).to(cTtoN).do(), "Basic chain to basic chain, null params");
    assertEquals(3, chain(cTtoT, 1).to(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals([2, false], chain(cTtoT, 0).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals([3, true], chain(cTtoT, 1).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
}
