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
    assertEquals(1, probe(cNtoT, 0).do(), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(0, probe(cNtoT, null).do(), "Optional Chaining callable should be able to start on callables accepting null");
    assertEquals(1, probe(cTtoT, 0).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals(null, probe(cTtoT, null).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals("invalid", probe(cTtoT, "invalid").do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
    assertEquals([0, "invalid"], probe(cTtoT, [0, "invalid"]).do(), "Optional Chaining callable should be able to start on callables NOT accepting null");
}

shared test void testChainProbe() {
    // For callables accepting null types
    assertEquals(2, chain(cTtoN, 0).probe(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(cTtoN, 1).probe(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");
    assertEquals(0, chain(cNtoN, null).probe(cNtoT).do(), "Conditional composition should be able to compose on callables accepting null");

    // For callables NOT accepting null types
    assertEquals(2, chain(cTtoN, 0).probe(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cTtoN, 1).probe(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
    assertEquals(null, chain(cNtoN, null).probe(cTtoT).do(), "Conditional composition should be able to compose on callables not accepting null.");
}

shared test void testProbingMethods() {
    //to
    assertEquals(2, probe(cTtoT, 0).to(cTtoT).do(), "Probe matchin chained to a simple shain");
    assertEquals(false, probe(cTtoT, false).to(cTTtoT).do(), "Probe non-matching chained to a simple chain");

    //spread
    assertEquals([2, true], probe(cTtoI, 1).spread(cTItoS).do(), "Probe matchin chained to a spread");
    assertEquals([1, false], probe(cTtoI, { 1,0 }).spread(cTItoS).do(), "Probe non-matching chained to a spread");

    //probe
    assertEquals(2, probe(cTtoI, 2).probe(cItoT).do(), "Probe matchin chained to another probe");
    assertEquals(1, probe(cTtoI, {2}).probe(cItoT).do(), "Probe NON-matchin chained to another probe");

    Integer|{Integer*} do = iterate(cTtoI, 2).probe(cTtoT).do();
    assert (is {Integer*} do);
    assertTrue(iterableEquals({ 3, 1 }, do), "Probe chained to a non-matching probe: ``do``");

    //iterating
    value do2 = probe(cTtoI, 3).iterate(cTItoI).do();
    assertTrue(iterableEquals({ 6 }, do2), "Probe chained to an matching iterating ``do2``");
}