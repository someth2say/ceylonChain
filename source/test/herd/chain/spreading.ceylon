import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain, bwchain,
    spread, bwspread
}

shared test void testSpread() {
    //Starting from an spreadable
    assertEquals(2, spread(cTtoS, 0).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(cTtoS, 1).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(cNtoS, null).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    //Continuing from a non-spreadable...
    assertEquals(1, chain(cTtoT, 0).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(4, chain(cTtoT, 1).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, chain(cNtoT, null).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    // Optionally spreading
    assertEquals([1,true], spread(cTtoS, 0).probe(cTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(cTtoS, 1).probe(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    // Spreading
    assertEquals([2, true], spread(cTtoS, 0).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], spread(cTtoS, 1).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], spread(cNtoS, null).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
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
    assertEquals([1,true], bwspread(cTtoS).probe(cTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, bwspread(cTtoS).probe(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");

    // Spreading to an spreadable
    assertEquals([2, true], bwspread(cTtoS).spread(cTTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], bwspread(cTtoS).spread(cTTtoS).with(1), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], bwspread(cNtoS).spread(cTTtoS).with(null), "Spreadable composition should be able to compose on callables accepting null");
}

