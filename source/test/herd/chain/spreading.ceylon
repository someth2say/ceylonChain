import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain,
    spread,
    spreads
}

shared test void testSpreadStart() {
    assertEquals(2, spread(0, cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(1, cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(1, spread(null, cTNtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");

    assertEquals(2, spreads([0,true], cTTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");

}

shared test void testChainToSpread() {
    //Continuing from a non-spreadable...
    assertEquals(1, chain(0, cTtoT).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(4, chain(1, cTtoT).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, chain(null, cTNtoT).spread(cTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
}

shared test void testSpreadTo() {
    assertEquals(3, spread(0, cTtoS).spread(cTTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, spread(1, cTtoS).spread(cTTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(2, spread(null, cTNtoS).spread(cTTtoS).to(cTTtoT).do(), "Spreadable composition should be able to compose on callables accepting null");
}

shared test void testSpreadSpread(){
    assertEquals([2, true], spread(0, cTtoS).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([3, false], spread(1, cTtoS).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
    assertEquals([1, true], spread(null, cTNtoS).spread(cTTtoS).do(), "Spreadable composition should be able to compose on callables accepting null");
}

//TODO: Test spreads
