import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chain,
    Chain,
    opt,
    opts
}

shared test void testOptional() {
    assertEquals(1, opt<Integer,Null,Integer>(0, cTtoTN).do(), "Probing Chaining callable should be able to start on callables accepting null");
    assertEquals(null, opt<Integer,Null,Integer>(1, cTtoTN).do(), "Probing Chaining callable should be able to start on callables accepting null");

    assertEquals(1, opt<Integer,Null,Integer>(0, cTtoTN).to(cNtoT).do(), "Probing Chaining callable should be able to start on callables accepting null");
    assertEquals(0, opt<Integer,Null,Integer>(1, cTtoTN).to(cNtoT).do(), "Probing Chaining callable should be able to start on callables accepting null");

    assertEquals("1", opt<Null,Integer,Integer>(0, cTtoTN).to(Integer.string).do(), "Probing Chaining callable should be able to start on callables accepting null");
    assertEquals(null, opt<Null,Integer,Integer>(1, cTtoTN).to(Integer.string).do(), "Probing Chaining callable should be able to start on callables accepting null");

    assertEquals(2, opts<Integer,Null,[Integer, Boolean]>([1, true], cTBtoTN).do(), "Probing Chaining callable should be able to start on callables accepting null");
    assertEquals(null, opts<Integer,Null,[Integer, Boolean]>([1, false], cTBtoTN).do(), "Probing Chaining callable should be able to start on callables accepting null");

}


shared test void testChainOptional() {
    // For callables accepting null types
    assertEquals(null, chain(0, cTtoT).opt<Integer,Null>(cTtoTN).do(), "Optional chain should work like a basic chain (1)");
    assertEquals(3, chain(1, cTtoT).opt<Integer,Null>(cTtoTN).do(), "Optional chain should work like a basic chain (2)");

    Chain<String?> r3 = chain(0, cTtoT).opt<Null,Integer>(cTtoTN).to(Integer.string);
    assertEquals(null, r3.do(), "Optional chain Keep type should be retain, and Handled type should be changed (1)");
    Chain<String?> r4 = chain(1, cTtoT).opt<Null,Integer>(cTtoTN).to(Integer.string);
    assertEquals("3", r4.do(), "Optional chain Keep type should be retain, and Handled type should be changed (2)");

    Chain<Integer> r5 = chain(0, cTtoT).opt<Integer,Null>(cTtoTN).to(cNtoT);
    assertEquals(0, r5.do(), "Optional chain should colapse types when Handled type is transformed to Keep (1)");
    Chain<Integer> r6 = chain(1, cTtoT).opt<Integer,Null>(cTtoTN).to(cNtoT);
    assertEquals(3, r6.do(), "Optional chain should colapse types when Handled type is transformed to Keep (2)");

}

shared test void testProbing2Methods() {
//    //to
//    assertEquals(2, probe(0, cTtoT).to(cTtoT).do(), "Probe matchin chained to a simple shain");
//    assertEquals(false, probe(false, cTtoT).to(cUtoT).do(), "Probe non-matching chained to a simple chain");
//
//    //spread
//    assertEquals([1, false], probe(1, cTtoI).spread(cUItoS).do(), "Probe matching chained to a spread");
//    assertEquals([2, true], probe({ 2, 0 }, cTtoI).spread(cUItoS).do(), "Probe non-matching chained to a spread");
//
//    //probe
//    assertEquals(3, probe(2, cTtoI).probe(cItoT).do(), "Probe matchin chained to another probe");
//    assertEquals(1, probe({ 2 }, cTtoI).probe(cItoT).do(), "Probe NON-matchin chained to another probe");
//
//    //iterating
//    value do2 = probe(3, cTtoI).iterate(cUItoI).do();
//    assertTrue(deepEquals({ 6 }, do2), "Probe chained to an matching iterating ``do2``");
}