import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain,
    spread
}

import herd.chain.bwchain {
    bwchain,
    bwspread
}

shared test void testSpread() {
    //Starting from an spreadable
    assertEquals(2, spread(0, cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(1, cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(null, cNtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    //Continuing from a non-spreadable...
    assertEquals(1, chain(0, cTtoT).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(4, chain(1, cTtoT).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, chain(null, cNtoT).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    // Optionally spreading
    assertEquals([1, true], spread(0, cTtoS).probe(cTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(1, cTtoS).probe(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    // Spreading
    assertEquals([2, true], spread(0, cTtoS).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], spread(1, cTtoS).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], spread(null, cNtoS).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
}

shared test void testBwSpread() {
    //Starting from an spreadable
    assertEquals(2, bwspread(cTtoS).to(cTTtoT).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, bwspread(cTtoS).to(cTTtoT).with(1), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, bwspread(cNtoS).to(cTTtoT).with(null), "Spreadable composition should be able to compose on callables accepting null");

    //Continuing from a non-spreadable...
    assertEquals(1, bwchain(cTtoT).spread(cTtoS).to(cTTtoT).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(4, bwchain(cTtoT).spread(cTtoS).to(cTTtoT).with(1), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, bwchain(cNtoT).spread(cTtoS).to(cTTtoT).with(null), "Spreadable composition should be able to compose on callables accepting null");

    // Optionally spreading
    assertEquals([1, true], bwspread(cTtoS).probe(cTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, bwspread(cTtoS).probe(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");

    // Spreading to an spreadable
    assertEquals([2, true], bwspread(cTtoS).spread(cTTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], bwspread(cTtoS).spread(cTTtoS).with(1), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], bwspread(cNtoS).spread(cTTtoS).with(null), "Spreadable composition should be able to compose on callables accepting null");
}

