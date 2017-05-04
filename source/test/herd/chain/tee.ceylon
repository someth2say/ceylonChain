import ceylon.test {
    test,
    assertEquals,
    fail
}

import herd.chain {
    chainTo,
    tee,
    Chain
}


shared test void testTee() {
    // Chain start and parameter setting
    assertEquals(tee(0, cTtoT).do(), 0, "Basic tee");
    assertEquals(tee(null, cTNtoT).do(), null, "Basic tee, null params");
    assertEquals(tee([1, true], cStoS).do(), [1, true], "Basic tee, tuple params");
}

shared test void testTeeSample() {
    Chain<Integer> ch = chainTo(1, Integer.successor);
    Chain<Integer> ch2 = ch.tee((Integer i) { if (i.negative) {fail();}});
    assertEquals(ch2.do(), 2);
}

shared test void testTeeTo() {
    assertEquals(tee(0, cTtoT).to(cTtoT).do(), 1, "Basic tee to basic chain");
    assertEquals(tee(null, cTNtoT).to(cNtoT).do(), 0, "Basic tee to basic chain, null params");
}

shared test void testChainToTee() {
    assertEquals(chainTo(0, cTtoT).tee(cTtoT).do(), 1, "Basic tee to basic chain");
    assertEquals(chainTo(null, cTNtoT).tee(cTtoI).do(), 0, "Basic tee to basic chain, null params");
}
