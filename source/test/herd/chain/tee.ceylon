import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain,
    tee,
    tees

}


shared test void testTee() {
    // Chain start and parameter setting
    assertEquals(0, tee(0, cTtoT).do(), "Basic tee");
    assertEquals(null, tee(null, cTNtoT).do(), "Basic tee, null params");
    assertEquals([1, true], tee([1, true], cStoS).do(), "Basic tee, tuple params");
    assertEquals([1, true], tees([1, true], cTTtoT).do(), "Spreading tee");

}

shared test void testTeeTo() {
    assertEquals(1, tee(0, cTtoT).to(cTtoT).do(), "Basic tee to basic chain");
    assertEquals(0, tee(null, cTNtoT).to(cNtoT).do(), "Basic tee to basic chain, null params");
}

shared test void testChainToTee() {
    assertEquals(1, chain(0, cTtoT).tee(cTtoT).do(), "Basic tee to basic chain");
    assertEquals(0, chain(null, cTNtoT).tee(cTtoI).do(), "Basic tee to basic chain, null params");
}
