import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain,
    spread
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

