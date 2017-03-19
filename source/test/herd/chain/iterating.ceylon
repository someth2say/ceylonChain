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
    assertTrue(iterableEquals({ 3, 1 },chain(cTtoT,1).iterate(cTtoI).do()),"Iterable composition after a chain");
}

shared test void testIteratingMethods(){
    //to
    assertEquals(2,iterate(cTtoI,0).to(cItoT).do(),"Iterate chained to a simple chainable");

    //spread
    assertEquals([2,true],iterate(cTtoI,1).spread(cItoS).do(),"Iterate chained to an spreadable");

    //probe
    assertEquals(2,iterate(cTtoI,2).probe(cItoT).do(),"Iterate chained to a matching probe");
    Integer|{Integer*} do = iterate(cTtoI,2).probe(cTtoT).do();
    assert(is {Integer*} do);
    assertTrue(iterableEquals({3,1},do),"Iterate chained to a non-matching probe: ``do``");

    //iterating
    value do2 = iterate(cTtoI,3).iterate(cItoI).do();
    assertTrue(iterableEquals({true,true},do2),"Iterate chained to an iterating ``do2``");
}

shared test void testStreamMethods(){
    // Apply map operation
    assertTrue(iterableEquals({ 2, 0 }, iterate(cTtoI, 0).map(Integer.successor).do()), "Iterable composition should be able to map iterable elements");

    // Apply fold operation
    assertEquals(6, (iterate(cTtoI, 2).fold(2, (Integer a, Integer b) => a + b).do()), "Iterable composition should be able to fold iterable elements");

    variable Integer accum = 0;
    {Integer*} result = iterate(cTtoI, 2).each((Integer p) => accum += p).do();
    assertTrue(iterableEquals({3,1},result),"Iterable composition should be able to step each element of an iterable");
    assertEquals(4, accum, "Iterable composition should be able to step each element of an iterable");

    // Collect
    assertEquals([2, 0], iterate(cTtoI, 1).collect(identity<Integer>).do(), "Iterable composition should be able to collect iterable elements");
}
