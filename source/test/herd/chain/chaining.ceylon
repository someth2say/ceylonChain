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
    assertEquals(0, chain(null, cTNtoT).do(), "Basic chain, null params");
    assertEquals(null, chain(1, cTtoTN).do(), "Basic chain, null params, null return");
    assertEquals([2, true], chain([1, true], cStoS).do(), "Basic chain, tuple params, tuple return");
    assertEquals([1, true], chain(0, cTtoS).do(), "Basic chain, tuple return ");
    assertEquals([0, true], chain(null, cTNtoS).do(), "Basic chain, null params, tuple return");
    assertEquals(4, chain(4, Integer).do(), "Basic chain onto a constructor");

    assertEquals(3, chain({ 1, 2, 3 }, ({Integer*} ints) => ints.find(Integer.even)).force((Null n) => 0).to(Integer.successor).do(), "Chain on iterable 1");
    assertEquals(1, chain({ 1, 3, 5 }, ({Integer*} ints) => ints.find(Integer.even)).force((Null n) => 0).to(Integer.successor).do(), "Chain on iterable 2");
}

shared test void testChainSpread() {
    assertEquals(2, chains([1, true], cTTtoT).do(), "Basic chain, spreading params");
}

shared test void testChainTo() {
    assertEquals(2, chain(0, cTtoT).to(cTtoT).do(), "Basic chain to basic chain");
    assertEquals(1, chain(null, cTNtoT).to(cTtoT).do(), "Basic chain to basic chain, null params");
    assertEquals(0, chain(null, cTNtoTN).to(cTNtoT).do(), "Basic chain to basic chain, null params, null return");

    assertEquals(null, chain(0, cTtoT).to(cTtoTN).do(), "Basic chain to basic chain, null params");
    assertEquals(3, chain(1, cTtoT).to(cTtoTN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals([2, false], chain(0, cTtoT).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals([3, true], chain(1, cTtoT).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
}
