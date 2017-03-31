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
    assertTrue(deepEquals({ 0, 1, 2 }, chain(1, cTtoT).iterate(cTtoI).do()), "Iterable composition after a chain");
    assertTrue(deepEquals({ 0, 1 }, iterate(1, cTtoI).do()), "Iterable start");
}

shared test void testIteratingMethods() {
    //to
    assertEquals(6, iterate(5, cTtoI).to(cItoT).do(), "Iterate chained to a simple chainable");

    //spread
    assertEquals([2, true], iterate(1, cTtoI).spread(cItoS).do(), "Iterate chained to an spreadable");

    //probe
    assertEquals(3, iterate(2, cTtoI).probe(cItoT).do(), "Iterate chained to a matching probe");
    Integer|{Integer*} do = iterate(2, cTtoI).probe(cTtoT).do();
    assert (is {Integer*} do);
    assertTrue(deepEquals({ 0, 1, 2 }, do), "Iterate chained to a non-matching probe: ``do``");

    //iterating
    value do2 = iterate(3, cTtoI).iterate(cItoI).do();
    assertTrue(deepEquals({ true, false, true, false }, do2), "Iterate chained to an iterating ``do2``");
}

shared test void testStreamMethods() {

    assertEquals(iterate(3, cTtoI).any(2.equals).do(), true, "Iterable any");
    assertEquals(iterate(3, cTtoI).any(4.equals).do(), false, "Iterable any");
    assertTrue(deepEquals({ 0, 2, 4 }, iterate(5, cTtoI).by(2).do()), "Iterable by");
    assertTrue(deepEquals({ 0, 1, 2, -1, -2 }, iterate(2, cTtoI).chain({ -1, -2 }).do()), "Iterable chain");
    value collect = iterate(2, cTtoI).collect(Integer.successor).do();
    assertTrue(deepEquals([1, 2, 3], collect), "Iterable collect: ``collect```");

    assertEquals(iterate(3, cTtoI).contains(2).do(), true, "Iterable contains");
    assertEquals(iterate(3, cTtoI).contains(4).do(), false, "Iterable contains");
    assertEquals(iterate(3, cTtoI).count(Integer.even).do(), 2, "Iterable count");
    assertTrue(deepEquals({ 0, 1, 0 }, iterate(1, cTtoI).chain({ null }).defaultNullElements(0).do()), "Iterable defaultNullElements");
    variable Integer accum = 0;
    {Integer*} result = iterate(2, cTtoI).each((Integer p) => accum += p).do();
    assertTrue(deepEquals({ 0, 1, 2 }, result), "Iterable each");
    assertEquals(3, accum, "Iterable each collateral");
    assertEquals(iterate(3, cTtoI).every(Integer.even).do(), false, "Iterable every");
    assertEquals(iterate(3, cTtoI).every(4.largerThan).do(), true, "Iterable every");
    assertTrue(deepEquals({ 0, 2, 4 }, iterate(5, cTtoI).filter(Integer.even).do()), "Iterable filter");
    assertEquals(iterate(10, cTtoI).find(4.smallerThan).do(), 5, "Iterable find");
    assertEquals(iterate(10, cTtoI).findLast(4.divides).do(), 8, "Iterable findLast");
    assertTrue(deepEquals({ '9', '1', '0' }, iterate(10, cTtoI).filter(8.smallerThan).flatMap(Integer.string).do()), "Iterable flatMap");
    assertEquals(5, (iterate(2, cTtoI).fold(2, plus<Integer>).do()), "Iterable fold");
    assertTrue(deepEquals({ -1, 0, 1 }, iterate(1, cTtoI).follow(-1).do()), "Iterable follow");
    assertTrue(deepEquals({ 0->1, 1->1, 2->2 }, iterate(2, cTtoI).follow(2).frequencies().do()), "Iterable frequencies");
    assertEquals(iterate(2, cTtoI).repeat(3).getFromFirst(4).do(), 1, "Iterable getFromFirst");
    assertTrue(iterate(2, cTtoI).group(Integer.even).do().containsEvery({ true->[0, 2], false->[1] }), "Iterable group");
    assertTrue(deepEquals({ 0, 1, 2, 3 }, iterate(3, cTtoI).indexes().do()), "Iterable indexes");
    assertTrue(deepEquals({ 0, -1, 1, -1, 2, -1, 3 }, iterate(3, cTtoI).interpose(-1).do()), "Iterable interpose");

    // TODO: Find a way to validate the iterator.
    //assertTrue(iterate(2, cTtoI).iterator().do(),??, "Iterable iterator");

    assertEquals(iterate(6, cTtoI).locate(4.smallerThan).do(), 5->5, "Iterable locate");
    assertEquals(iterate(5, cTtoI).locateLast(Integer.even).do(), 4->4, "Iterable locateLast");
    assertTrue(iterate(3, cTtoI).locations(Integer.even).do().containsEvery({ 0->0, 2->2 }), "Iterable locations");
    assertEquals(iterate(3, cTtoI).longerThan(3).do(), true, "Iterable longerThan");
    assertEquals(iterate(3, cTtoI).longerThan(4).do(), false, "Iterable longerThan");
    assertTrue(deepEquals({ 1, 2, 3 }, iterate(2, cTtoI).map(Integer.successor).do()), "Iterable map");
    assertEquals(iterate(3, cTtoI).max((a, b) => a.compare(b)).do(), 3, "Iterable max");
    assertTrue(deepEquals({ 0, 1, 2 }, iterate(2, cTtoI).follow("one").follow(null).narrow<Integer>().do()), "Iterable narrow");
    assertTrue(deepEquals({ [0, 1], [2, 3], [4] }, iterate(4, cTtoI).partition(2).do()), "Iterable partition");
    assertTrue(deepEquals({ [0, 'a'], [0, 'b'], [1, 'a'], [1, 'b'] }, iterate(1, cTtoI).product({ 'a', 'b' }).do()), "Iterable product");
    assertEquals(iterate(2, cTtoI).reduce(plus<Integer>).do(), 3, "Iterable reduce");
    value repeat = iterate(2, cTtoI).repeat(2).do();
    assertTrue(deepEquals([0, 1, 2, 0, 1, 2], repeat), "Iterable repeat: ``repeat``(``repeat.rest``)");
    assertTrue(deepEquals({ 2, 2, 3, 5 }, iterate(2, cTtoI).scan(2, plus<Integer>).do()), "Iterable scan");
    assertTrue(deepEquals([0, 2, 4], iterate(5, cTtoI).select(Integer.even).do()), "Iterable select");

    // TODO: Find a way to validate sequence
    //assertTrue(iterate(2, cTtoI).sequence().do(),??, "Iterable sequence");

    assertEquals(iterate(3, cTtoI).shorterThan(4).do(), false, "Iterable shorterThan");
    assertEquals(iterate(3, cTtoI).shorterThan(5).do(), true, "Iterable shorterThan");
    assertTrue(deepEquals({ 3, 4, 5 }, iterate(5, cTtoI).skip(3).do()), "Iterable skip");
    assertTrue(deepEquals({ 3, 4, 5 }, iterate(5, cTtoI).skipWhile(3.largerThan).do()), "Iterable skipWhile");
    assertTrue(deepEquals({ 5, 4, 3, 2, 1, 0 }, iterate(5, cTtoI).sort((x, y) => y.compare(x)).do()), "Iterable sort");
    assertTrue(deepEquals({ 3, 4, 5, 6, 7, 8 }, iterate(5, cTtoI).spreadIterable(Integer.plus).do()(3)), "Iterable spreadIterable");
    assertTrue(iterate(5, cTtoI).summarize(Integer.even, (Integer? x, Integer y) => if (exists x ) then x + y else y).do().containsEvery({ true->6, false->9 }), "Iterable summarize");
    value tabulate = iterate(5, cTtoI).tabulate(2.divides).do();
    assertTrue(tabulate.containsEvery({ 0->true, 1->false, 2->true, 3->false, 4->true, 5->false }), "Iterable tabulate: ``tabulate``");
    assertTrue(deepEquals({ 0, 1, 2 }, iterate(5, cTtoI).take(3).do()), "Iterable take");
    assertTrue(deepEquals({ 0, 1, 2 }, iterate(5, cTtoI).takeWhile(3.largerThan).do()), "Iterable takeWhile");
}
