import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    nullTry
}

shared test void testNullSkip() {
    Integer? notNull = 0;
    Integer? isNull = null;
    assertEquals(1, nullTry(notNull, cTtoT).do(), "NullSkipping start passing a matching not-null parameter");
    assertEquals(null, nullTry(isNull, cTtoT).do(), "NullSkipping start passing a non-matching null parameter");
    assertEquals(null, nullTry(isNull, cTNtoT).do(), "NullSkipping start passing a matching null parameter");
}
//
//shared test void testChainNullSkip() {
//    // For callables accepting null types
//    assertEquals(2, chain(0, cTtoTN).probe(cTNtoT).do(), "Probing composition should be able to compose on callables accepting null");
//    assertEquals(0, chain(1, cTtoTN).probe(cTNtoT).do(), "Probing composition should be able to compose on callables accepting null");
//    assertEquals(0, chain(null, cTNtoTN).probe(cTNtoT).do(), "Probing composition should be able to compose on callables accepting null");
//
//    // For callables NOT accepting null types
//    assertEquals(2, chain(0, cTtoTN).probe(cTtoT).do(), "Probing composition should be able to compose on callables not accepting null.");
//    assertEquals(null, chain(1, cTtoTN).probe(cTtoT).do(), "Probing composition should be able to compose on callables not accepting null.");
//    assertEquals(null, chain(null, cTNtoTN).probe(cTtoT).do(), "Probing composition should be able to compose on callables not accepting null.");
//}
//
//shared test void testNullSkippingMethods() {
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
//    Integer|{Integer*} do = iterate(2, cTtoI).probe(cTtoT).do();
//    assert (is {Integer*} do);
//    assertTrue(deepEquals({ 0, 1, 2 }, do), "Probe chained to a non-matching probe: ``do``");
//
//    //iterating
//    value do2 = probe(3, cTtoI).iterate(cUItoI).do();
//    assertTrue(deepEquals({ 6 }, do2), "Probe chained to an matching iterating ``do2``");
//}