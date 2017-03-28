import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chain,
    iterate
}

shared test void testIterate() {
    assertTrue(iterableEquals({ 3, 1 }, chain(1, cTtoT).iterate(cTtoI).do()), "Iterable composition after a chain");
    assertTrue(iterableEquals({ 2, 0 }, iterate(1, cTtoI).do()), "Iterable start");
}

shared test void testIteratingMethods() {
    //to
    assertEquals(2, iterate(0, cTtoI).to(cItoT).do(), "Iterate chained to a simple chainable");

    //spread
    assertEquals([2, true], iterate(1, cTtoI).spread(cItoS).do(), "Iterate chained to an spreadable");

    //probe
    assertEquals(2, iterate(2, cTtoI).probe(cItoT).do(), "Iterate chained to a matching probe");
    Integer|{Integer*} do = iterate(2, cTtoI).probe(cTtoT).do();
    assert (is {Integer*} do);
    assertTrue(iterableEquals({ 3, 1 }, do), "Iterate chained to a non-matching probe: ``do``");

    //iterating
    value do2 = iterate(3, cTtoI).iterate(cItoI).do();
    assertTrue(iterableEquals({ true, true }, do2), "Iterate chained to an iterating ``do2``");
}

shared test void testStreamMethods() {
    // Apply map operation
    assertTrue(iterableEquals({ 2, 0 }, iterate(0, cTtoI).map(Integer.successor).do()), "Iterable composition should be able to map iterable elements");

    // Apply fold operation
    assertEquals(6, (iterate(2, cTtoI).fold(2, (Integer a, Integer b) => a + b).do()), "Iterable composition should be able to fold iterable elements");

    variable Integer accum = 0;
    {Integer*} result = iterate(2, cTtoI).each((Integer p) => accum += p).do();
    assertTrue(iterableEquals({ 3, 1 }, result), "Iterable composition should be able to step each element of an iterable");
    assertEquals(4, accum, "Iterable composition should be able to step each element of an iterable");

    // Collect
    assertEquals([2, 0], iterate(1, cTtoI).collect(identity<Integer>).do(), "Iterable composition should be able to collect iterable elements");
}
