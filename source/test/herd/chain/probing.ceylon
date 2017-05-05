import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chainTo,
    probe
}

shared test void testProbe() {
    assertEquals(probe(0, cTNtoT).do(), 1, "Probing Chaining callable should be able to start on callables accepting null");
    assertEquals(probe(null, cTNtoT).do(), 0, "Probing Chaining callable should be able to start on callables accepting null");
    assertEquals(probe(0, cTtoT).do(), 1, "Probing Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(probe(null, cTtoT).do(), null, "Probing Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(probe("invalid", cTtoT).do(), "invalid", "Probing Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(probe([0, "invalid"], cTtoT).do(), [0, "invalid"], "Probing Chaining callable should be able to start on callables NOT accepting null");

    assertEquals(probe(null, cTtoV).to(cNtoT).do(), 0, "Probing a 'Nothing' returning function: as it does not match, 'nothing' is not evaluated.");

}

shared test void testChainProbe() {
    // For callables accepting null types
    assertEquals(chainTo(0, cTtoTN).probe(cTNtoT).do(), 2, "Probing composition should be able to compose on callables accepting null");
    assertEquals(chainTo(1, cTtoTN).probe(cTNtoT).do(), 0, "Probing composition should be able to compose on callables accepting null");
    assertEquals(chainTo(null, cTNtoTN).probe(cTNtoT).do(), 0, "Probing composition should be able to compose on callables accepting null");

    // For callables NOT accepting null types
    assertEquals(chainTo(0, cTtoTN).probe(cTtoT).do(), 2, "Probing composition should be able to compose on callables not accepting null.");
    assertEquals(chainTo(1, cTtoTN).probe(cTtoT).do(), null, "Probing composition should be able to compose on callables not accepting null.");
    assertEquals(chainTo(null, cTNtoTN).probe(cTtoT).do(), null, "Probing composition should be able to compose on callables not accepting null.");
}

shared test void testProbingMethods() {
    //to
    assertEquals(probe(0, cTtoT).to(cTtoT).do(), 2, "Probe matchin chained to a simple shain");
    assertEquals(probe(false, cTtoT).to(cUtoT).do(), false, "Probe non-matching chained to a simple chain");

    //spread
    assertEquals(probe(1, cTtoI).spread(cUItoS).do(), [1, false], "Probe matching chained to a spread");
    assertEquals(probe({ 2, 0 }, cTtoI).spread(cUItoS).do(), [2, true], "Probe non-matching chained to a spread");

    //probe
    assertEquals(probe(2, cTtoI).probe(cItoT).do(), 3, "Probe matchin chained to another probe");
    assertEquals(probe({ 2 }, cTtoI).probe(cItoT).do(), 1, "Probe NON-matchin chained to another probe");

    //iterating
    value do2 = probe(3, cTtoI).iterate(cUItoI).do();
    assertTrue(deepEquals({ 6 }, do2), "Probe chained to an matching iterating ``do2``");
}