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
    assertEquals(chain(0, cTtoT).do(), 1, "Basic chain");
    assertEquals(chain(null, cTNtoT).do(), 0, "Basic chain, null params");
    assertEquals(chain(1, cTtoTN).do(), null, "Basic chain, null params, null return");
    assertEquals(chain([1, true], cStoS).do(), [2, true], "Basic chain, tuple params, tuple return");
    assertEquals(chain(0, cTtoS).do(), [1, true], "Basic chain, tuple return ");
    assertEquals(chain(null, cTNtoS).do(), [0, true], "Basic chain, null params, tuple return");
    assertEquals(chain(4, Integer).do(), 4, "Basic chain onto a constructor");
}

shared test void testChainSpread() {
    assertEquals(chains([1, true], cTTtoT).do(), 2, "Basic chain, spreading params");
}

shared test void testChainTo() {
    assertEquals(chain(0, cTtoT).to(cTtoT).do(), 2, "Basic chain to basic chain");
    assertEquals(chain(null, cTNtoT).to(cTtoT).do(), 1, "Basic chain to basic chain, null params");
    assertEquals(chain(null, cTNtoTN).to(cTNtoT).do(), 0, "Basic chain to basic chain, null params, null return");

    assertEquals(chain(0, cTtoT).to(cTtoTN).do(), null, "Basic chain to basic chain, null params");
    assertEquals(chain(1, cTtoT).to(cTtoTN).do(), 3, "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals(chain(0, cTtoT).to(cTtoS).do(), [2, false], "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(chain(1, cTtoT).to(cTtoS).do(), [3, true], "Chained callables should be equivalent to invonking those callables in the opposing order.");
}
