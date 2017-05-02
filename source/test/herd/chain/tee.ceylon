import ceylon.test {
    test,
    assertEquals,
    fail
}

import herd.chain {
    chain,
    tee,
    tees,
    Chain

}


shared test void testTee() {
    // Chain start and parameter setting
    assertEquals(tee(0, cTtoT).do(), 0, "Basic tee");
    assertEquals(tee(null, cTNtoT).do(), null, "Basic tee, null params");
    assertEquals(tee([1, true], cStoS).do(), [1, true], "Basic tee, tuple params");
    assertEquals(tees([1, true], cTTtoT).do(), [1, true], "Spreading tee");
}

shared test void testTeeSample() {
    Chain<Integer> ch = chain(1, Integer.successor);
    Chain<Integer> ch2 = ch.tee((Integer i) { if (i.negative) {fail();}});
    assertEquals(ch2.do(), 2);
}

shared test void testTeeTo() {
    assertEquals(tee(0, cTtoT).to(cTtoT).do(), 1, "Basic tee to basic chain");
    assertEquals(tee(null, cTNtoT).to(cNtoT).do(), 0, "Basic tee to basic chain, null params");
}

shared test void testChainToTee() {
    assertEquals(chain(0, cTtoT).tee(cTtoT).do(), 1, "Basic tee to basic chain");
    assertEquals(chain(null, cTNtoT).tee(cTtoI).do(), 0, "Basic tee to basic chain, null params");
}
