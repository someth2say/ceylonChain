import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chain,
    probe,
    iterate
}

shared test void testProbe() {
    assertEquals(1, probe(0, cNtoT).do(), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(0, probe(null, cNtoT).do(), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(1, probe(0, cTtoT).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(null, probe(null, cTtoT).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals("invalid", probe("invalid", cTtoT).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals([0, "invalid"], probe([0, "invalid"], cTtoT).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
}

shared test void testChainProbe() {
    // For callables accepting null types
    assertEquals(2, chain(0, cTtoN).probe(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(1, cTtoN).probe(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(null, cNtoN).probe(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");

    // For callables NOT accepting null types
    assertEquals(2, chain(0, cTtoN).probe(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(1, cTtoN).probe(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(null, cNtoN).probe(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
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

    Integer|{Integer*} do = iterate(2, cTtoI).probe(cTtoT).do();
    assert (is {Integer*} do);
    assertTrue(deepEquals({ 0, 1, 2 }, do), "Probe chained to a non-matching probe: ``do``");

    //iterating
    value do2 = probe(3, cTtoI).iterate(cUItoI).do();
    assertTrue(deepEquals({ 6 }, do2), "Probe chained to an matching iterating ``do2``");
}