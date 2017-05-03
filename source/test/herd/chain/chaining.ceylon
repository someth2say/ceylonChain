import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chainTo,
    chain
}


shared test void testChainF() {
    // Chain start and parameter setting
    assertEquals(chainTo(0, cTtoT).do(), 1, "Basic chain");
    assertEquals(chainTo(null, cTNtoT).do(), 0, "Basic chain, null params");
    assertEquals(chainTo(1, cTtoTN).do(), null, "Basic chain, null params, null return");
    assertEquals(chainTo([1, true], cStoS).do(), [2, true], "Basic chain, tuple params, tuple return");
    assertEquals(chainTo(0, cTtoS).do(), [1, true], "Basic chain, tuple return ");
    assertEquals(chainTo(null, cTNtoS).do(), [0, true], "Basic chain, null params, tuple return");
    assertEquals(chainTo(4, Integer).do(), 4, "Basic chain onto a constructor");
}

shared test void testChain() {
    // Chain start and parameter setting
    assertEquals(chain(0).to(cTtoT).do(), 1, "Basic chain");
    assertEquals(chain(null).to(cTNtoT).do(), 0, "Basic chain, null params");
    assertEquals(chain(1).to(cTtoTN).do(), null, "Basic chain, null params, null return");
    assertEquals(chain([1, true]).to(cStoS).do(), [2, true], "Basic chain, tuple params, tuple return");
    assertEquals(chain(0).to(cTtoS).do(), [1, true], "Basic chain, tuple return ");
    assertEquals(chain(null).to( cTNtoS).do(), [0, true], "Basic chain, null params, tuple return");
    assertEquals(chain(4).to(Integer).do(), 4, "Basic chain onto a constructor");
}


shared test void testChainTo() {
    assertEquals(chainTo(0, cTtoT).to(cTtoT).do(), 2, "Basic chain to basic chain");
    assertEquals(chainTo(null, cTNtoT).to(cTtoT).do(), 1, "Basic chain to basic chain, null params");
    assertEquals(chainTo(null, cTNtoTN).to(cTNtoT).do(), 0, "Basic chain to basic chain, null params, null return");

    assertEquals(chainTo(0, cTtoT).to(cTtoTN).do(), null, "Basic chain to basic chain, null params");
    assertEquals(chainTo(1, cTtoT).to(cTtoTN).do(), 3, "Chained callables should be equivalent to invonking those callables in the opposing order.");

    assertEquals(chainTo(0, cTtoT).to(cTtoS).do(), [2, false], "Chained callables should be equivalent to invonking those callables in the opposing order.");
    assertEquals(chainTo(1, cTtoT).to(cTtoS).do(), [3, true], "Chained callables should be equivalent to invonking those callables in the opposing order.");
}
