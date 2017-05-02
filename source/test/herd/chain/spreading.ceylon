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
    assertEquals(spread(0, cTtoS).to(cTTtoT).do(), 2, "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(spread(1, cTtoS).to(cTTtoT).do(), 1, "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(spread(null, cTNtoS).to(cTTtoT).do(), 1, "Spreadable composition should be able to compose on callables accepting null");

    assertEquals(spreads([0,true], cTTtoS).to(cTTtoT).do(), 2, "Spreadable composition should be able to compose on callables accepting null");

}

shared test void testChainToSpread() {
    //Continuing from a non-spreadable...
    assertEquals(chain(0, cTtoT).spread(cTtoS).to(cTTtoT).do(), 1, "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(chain(1, cTtoT).spread(cTtoS).to(cTTtoT).do(), 4, "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(chain(null, cTNtoT).spread(cTtoS).to(cTTtoT).do(), 2, "Spreadable composition should be able to compose on callables accepting null");
}

shared test void testSpreadTo() {
    assertEquals(spread(0, cTtoS).spread(cTTtoS).to(cTTtoT).do(), 3, "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(spread(1, cTtoS).spread(cTTtoS).to(cTTtoT).do(), 2, "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(spread(null, cTNtoS).spread(cTTtoS).to(cTTtoT).do(), 2, "Spreadable composition should be able to compose on callables accepting null");
}

shared test void testSpreadSpread(){
    assertEquals(spread(0, cTtoS).spread(cTTtoS).do(), [2, true], "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(spread(1, cTtoS).spread(cTTtoS).do(), [3, false], "Spreadable composition should be able to compose on callables accepting null");
    assertEquals(spread(null, cTNtoS).spread(cTTtoS).do(), [1, true], "Spreadable composition should be able to compose on callables accepting null");
}

//TODO: Test spreads
