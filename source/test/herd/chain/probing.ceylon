import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chain,
    probe
}

shared test void testProbe() {
    assertEquals(1, probe(0, cTNtoT).do(), "Probing Chaining callable should be able to start on callables accepting null");
    assertEquals(0, probe(null, cTNtoT).do(), "Probing Chaining callable should be able to start on callables accepting null");
    assertEquals(1, probe(0, cTtoT).do(), "Probing Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(null, probe(null, cTtoT).do(), "Probing Chaining callable should be able to start on callables NOT accepting null");
    assertEquals("invalid", probe("invalid", cTtoT).do(), "Probing Chaining callable should be able to start on callables NOT accepting null");
    assertEquals([0, "invalid"], probe([0, "invalid"], cTtoT).do(), "Probing Chaining callable should be able to start on callables NOT accepting null");

    assertEquals(0, probe(null, cTtoV).to(cNtoT).do(), "Probing a 'Nothing' returning function: as it does not match, 'nothing' is not evaluated.");

}

shared test void testChainProbe() {
    // For callables accepting null types
    assertEquals(2, chain(0, cTtoTN).probe(cTNtoT).do(), "Probing composition should be able to compose on callables accepting null");
    assertEquals(0, chain(1, cTtoTN).probe(cTNtoT).do(), "Probing composition should be able to compose on callables accepting null");
    assertEquals(0, chain(null, cTNtoTN).probe(cTNtoT).do(), "Probing composition should be able to compose on callables accepting null");

    // For callables NOT accepting null types
    assertEquals(2, chain(0, cTtoTN).probe(cTtoT).do(), "Probing composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(1, cTtoTN).probe(cTtoT).do(), "Probing composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(null, cTNtoTN).probe(cTtoT).do(), "Probing composition should be able to compose on callables not accepting null.");
}

shared test void testProbingMethods() {
    //to
    assertEquals(2, probe(0, cTtoT).to(cTtoT).do(), "Probe matchin chained to a simple shain");
    assertEquals(false, probe(false, cTtoT).to(cUtoT).do(), "Probe non-matching chained to a simple chain");

    //spread
    assertEquals([1, false], probe(1, cTtoI).spread(cUItoS).do(), "Probe matching chained to a spread");
    assertEquals([2, true], probe({ 2, 0 }, cTtoI).spread(cUItoS).do(), "Probe non-matching chained to a spread");

    //probe
    assertEquals(3, probe(2, cTtoI).probe(cItoT).do(), "Probe matchin chained to another probe");
    assertEquals(1, probe({ 2 }, cTtoI).probe(cItoT).do(), "Probe NON-matchin chained to another probe");

    //iterating
    value do2 = probe(3, cTtoI).iterate(cUItoI).do();
    assertTrue(deepEquals({ 6 }, do2), "Probe chained to an matching iterating ``do2``");
}