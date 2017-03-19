import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain
}

shared test void testChain() {
    // Chain start and parameter setting
    assertEquals(1, chain(cTtoT, 0).do(), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals(0, chain(cNtoT, null).do(), "Invoking a ChainStart should directly invoke the method on the params");
    assertEquals([2, true], chain(cStoS, [1, true]).do(), "Invoking a ChainStart with sequential parameters");
}

shared test void testChainSpread() {
    // Chain start and parameter setting
    assertEquals([1, true], chain(cTtoS, 0).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([2, false], chain(cTtoS, 1).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
    assertEquals([0, true], chain(cNtoS, null).do(), "Invoking a ChainStart Spread should directly invoke the method on the params");
}

shared test void testChainTo() {
    assertEquals(2, chain(cTtoT, 0).to(cTtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(1, chain(cNtoT, null).to(cTtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(0, chain(cNtoN, null).to(cNtoT).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals(null, chain(cTtoT, 0).to(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(3, chain(cTtoT, 1).to(cTtoN).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals([2, false], chain(cTtoT, 0).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals([3, true], chain(cTtoT, 1).to(cTtoS).do(), "Chained callables should be equivalent to invonking those callables in the opposing order.");
}
