import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chainTo,
    spread,
    chainSpread
}

shared test void testSpreadStart() {
    assertEquals(spread([1,true]).to(cTTtoT).do(), 2, "Spreadable start (1)");
    assertEquals(spread([2,false]).to(cTTtoT).do(), 1, "Spreadable start (2)");
}
shared test void testSpreadF() {
    assertEquals(chainSpread(0, cTtoS).to(cTTtoT).do(), 2, "TBD");
    assertEquals(chainSpread(1, cTtoS).to(cTTtoT).do(), 1, "TBD");
    assertEquals(chainSpread(null, cTNtoS).to(cTTtoT).do(), 1, "TBD");
}

shared test void testChainToSpread() {
    //Continuing from a non-spreadable...
    assertEquals(chainTo(0, cTtoT).spread(cTtoS).to(cTTtoT).do(), 1, "TBD");
    assertEquals(chainTo(1, cTtoT).spread(cTtoS).to(cTTtoT).do(), 4, "TBD");
    assertEquals(chainTo(null, cTNtoT).spread(cTtoS).to(cTTtoT).do(), 2, "TBD");
}

shared test void testSpreadSpreadTo() {
    assertEquals(chainSpread(0, cTtoS).spread(cTTtoS).to(cTTtoT).do(), 3, "TBD");
    assertEquals(chainSpread(1, cTtoS).spread(cTTtoS).to(cTTtoT).do(), 2, "TBD");
    assertEquals(chainSpread(null, cTNtoS).spread(cTTtoS).to(cTTtoT).do(), 2, "TBD");
}

shared test void testSpreadSpread(){
    assertEquals(chainSpread(0, cTtoS).spread(cTTtoS).do(), [2, true], "TBD");
    assertEquals(chainSpread(1, cTtoS).spread(cTTtoS).do(), [3, false], "TBD");
    assertEquals(chainSpread(null, cTNtoS).spread(cTTtoS).do(), [1, true], "TBD");
}
