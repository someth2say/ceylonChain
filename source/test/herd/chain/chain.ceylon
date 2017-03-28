import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain,
    chains
}


shared test void testChain() {
    // Chain start and parameter setting
    assertEquals(1, chain(0, cTtoT).do(), "Basic chain");
    assertEquals(0, chain(null, cNtoT).do(), "Basic chain, null params");
    assertEquals(null, chain(1, cTtoN).do(), "Basic chain, null params, null return");
    assertEquals([2, true], chain([1, true], cStoS).do(), "Basic chain, tuple params, tuple return");
    assertEquals([1, true], chain(0, cTtoS).do(), "Basic chain, tuple return ");
    assertEquals([0, true], chain(null, cNtoS).do(), "Basic chain, null params, tuple return");
}

shared test void testChainSpread() {
    assertEquals(2, chains([1, true], cTTtoT).do(), "Basic chain, spreading params");
}

shared test void testChainTo() {
    assertEquals(2, chain(0, cTtoT).to(cTtoT).do(), "Basic chain to basic chain");
    assertEquals(1, chain(null, cNtoT).to(cTtoT).do(), "Basic chain to basic chain, null params");
    assertEquals(0, chain(null, cNtoN).to(cNtoT).do(), "Basic chain to basic chain, null params, null return");

    assertEquals(null, chain(0, cTtoT).to(cTtoN).do(), "Basic chain to basic chain, null params");
    assertEquals(3, chain(1, cTtoT).to(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals([2, false], chain(0, cTtoT).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals([3, true], chain(1, cTtoT).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
}
