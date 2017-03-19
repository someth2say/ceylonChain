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
    assertEquals(2, spread(cTtoS, 0).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(cTtoS, 1).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(cNtoS, null).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    //Continuing from a non-spreadable...
    assertEquals(1, chain(cTtoT, 0).spread(cTtoS).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(4, chain(cTtoT, 1).spread(cTtoS).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, chain(cNtoT, null).spread(cTtoS).to(cStoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    // Optionally spreading
    //    assertEquals(2, spread(cTtoS).thenOptionalyto(cTtoS).with(0), "Spreadable composition should be able to compose on callables accepting null");
    //    assertEquals(1, spread(cTtoS).thenOptionalyto(cStoT).with(1), "Spreadable composition should be able to compose on callables accepting null");

    // Spreading to an spreadable
    assertEquals([2, true], spread(cTtoS, 0).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], spread(cTtoS, 1).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], spread(cNtoS, null).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
}

