import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chainTo,
    iterate,
    chainIterate
}

shared test void testIterate() {
    assertTrue(deepEquals(chainTo(1, cTtoT).iterate(cTtoI).do(), { 0, 1, 2 }), "Iterable composition after a chain");
    assertTrue(deepEquals(iterate(0..1).do(), { 0, 1 }), "Iterable start");
}

shared test void testIterateF() {
    assertTrue(deepEquals(chainIterate(1, cTtoI).do(), { 0, 1 }), "Iterable start");
}

shared test void testIteratingMethods() {
    assertEquals(chainIterate(3, cTtoI).any(2.equals).do(), true, "Iterable any");
    assertEquals(chainIterate(3, cTtoI).any(4.equals).do(), false, "Iterable any");
    assertTrue(deepEquals({ 0, 2, 4 }, chainIterate(5, cTtoI).by(2).do()), "Iterable by");
    assertTrue(deepEquals({ 0, 1, 2, -1, -2 }, chainIterate(2, cTtoI).chain({ -1, -2 }).do()), "Iterable chain");
    value collect = chainIterate(2, cTtoI).collect(Integer.successor).do();
    assertTrue(deepEquals([1, 2, 3], collect), "Iterable collect: ``collect```");

    assertEquals(chainIterate(3, cTtoI).contains(2).do(), true, "Iterable contains");
    assertEquals(chainIterate(3, cTtoI).contains(4).do(), false, "Iterable contains");
    assertEquals(chainIterate(3, cTtoI).count(Integer.even).do(), 2, "Iterable count");
    assertTrue(deepEquals({ 0, 1, 0 }, chainIterate(1, cTtoI).chain({ null }).defaultNullElements(0).do()), "Iterable defaultNullElements");
    variable Integer accum = 0;
    {Integer*} result = chainIterate(2, cTtoI).each((Integer p) => accum += p).do();
    assertTrue(deepEquals({ 0, 1, 2 }, result), "Iterable each");
    assertEquals(3, accum, "Iterable each collateral");
    assertEquals(chainIterate(3, cTtoI).every(Integer.even).do(), false, "Iterable every");
    assertEquals(chainIterate(3, cTtoI).every(4.largerThan).do(), true, "Iterable every");
    assertTrue(deepEquals({ 0, 2, 4 }, chainIterate(5, cTtoI).filter(Integer.even).do()), "Iterable filter");
    assertEquals(chainIterate(10, cTtoI).find(4.smallerThan).do(), 5, "Iterable find");
    assertEquals(chainIterate(10, cTtoI).findLast(4.divides).do(), 8, "Iterable findLast");
    assertTrue(deepEquals({ '9', '1', '0' }, chainIterate(10, cTtoI).filter(8.smallerThan).flatMap(Integer.string).do()), "Iterable flatMap");
    assertEquals(5, (chainIterate(2, cTtoI).fold(2, plus<Integer>).do()), "Iterable fold");
    assertTrue(deepEquals({ -1, 0, 1 }, chainIterate(1, cTtoI).follow(-1).do()), "Iterable follow");
    assertTrue(deepEquals({ 0->1, 1->1, 2->2 }, chainIterate(2, cTtoI).follow(2).frequencies().do()), "Iterable frequencies");
    assertEquals(chainIterate(2, cTtoI).repeat(3).getFromFirst(4).do(), 1, "Iterable getFromFirst");
    assertTrue(chainIterate(2, cTtoI).group(Integer.even).do().containsEvery({ true->[0, 2], false->[1] }), "Iterable group");
    assertTrue(deepEquals({ 0, 1, 2, 3 }, chainIterate(3, cTtoI).indexes().do()), "Iterable indexes");
    assertTrue(deepEquals({ 0, -1, 1, -1, 2, -1, 3 }, chainIterate(3, cTtoI).interpose(-1).do()), "Iterable interpose");

    // TODO: Find a way to validate the iterator.
    //assertTrue(iterate(2, cTtoI).iterator().do(),??, "Iterable iterator");

    assertEquals(chainIterate(6, cTtoI).locate(4.smallerThan).do(), 5->5, "Iterable locate");
    assertEquals(chainIterate(5, cTtoI).locateLast(Integer.even).do(), 4->4, "Iterable locateLast");
    assertTrue(chainIterate(3, cTtoI).locations(Integer.even).do().containsEvery({ 0->0, 2->2 }), "Iterable locations");
    assertEquals(chainIterate(3, cTtoI).longerThan(3).do(), true, "Iterable longerThan");
    assertEquals(chainIterate(3, cTtoI).longerThan(4).do(), false, "Iterable longerThan");
    assertTrue(deepEquals({ 1, 2, 3 }, chainIterate(2, cTtoI).map(Integer.successor).do()), "Iterable map");
    assertEquals(chainIterate(3, cTtoI).max((a, b) => a.compare(b)).do(), 3, "Iterable max");
    assertTrue(deepEquals({ 0, 1, 2 }, chainIterate(2, cTtoI).follow("one").follow(null).narrow<Integer>().do()), "Iterable narrow");
    assertTrue(deepEquals({ [0, 1], [2, 3], [4] }, chainIterate(4, cTtoI).partition(2).do()), "Iterable partition");
    assertTrue(deepEquals({ [0, 'a'], [0, 'b'], [1, 'a'], [1, 'b'] }, chainIterate(1, cTtoI).product({ 'a', 'b' }).do()), "Iterable product");
    assertEquals(chainIterate(2, cTtoI).reduce(plus<Integer>).do(), 3, "Iterable reduce");
    value repeat = chainIterate(2, cTtoI).repeat(2).do();
    assertTrue(deepEquals([0, 1, 2, 0, 1, 2], repeat), "Iterable repeat: ``repeat``(``repeat.rest``)");
    assertTrue(deepEquals({ 2, 2, 3, 5 }, chainIterate(2, cTtoI).scan(2, plus<Integer>).do()), "Iterable scan");
    assertTrue(deepEquals([0, 2, 4], chainIterate(5, cTtoI).select(Integer.even).do()), "Iterable select");

    // TODO: Find a way to validate sequence
    //assertTrue(iterate(2, cTtoI).sequence().do(),??, "Iterable sequence");

    assertEquals(chainIterate(3, cTtoI).shorterThan(4).do(), false, "Iterable shorterThan");
    assertEquals(chainIterate(3, cTtoI).shorterThan(5).do(), true, "Iterable shorterThan");
    assertTrue(deepEquals({ 3, 4, 5 }, chainIterate(5, cTtoI).skip(3).do()), "Iterable skip");
    assertTrue(deepEquals({ 3, 4, 5 }, chainIterate(5, cTtoI).skipWhile(3.largerThan).do()), "Iterable skipWhile");
    assertTrue(deepEquals({ 5, 4, 3, 2, 1, 0 }, chainIterate(5, cTtoI).sort((x, y) => y.compare(x)).do()), "Iterable sort");
    assertTrue(deepEquals({ 3, 4, 5, 6, 7, 8 }, chainIterate(5, cTtoI).spread(Integer.plus).do()(3)), "Iterable spreadIterable");
    assertTrue(chainIterate(5, cTtoI).summarize(Integer.even, (Integer? x, Integer y) => if (exists x ) then x + y else y).do().containsEvery({ true->6, false->9 }), "Iterable summarize");
    value tabulate = chainIterate(5, cTtoI).tabulate(2.divides).do();
    assertTrue(tabulate.containsEvery({ 0->true, 1->false, 2->true, 3->false, 4->true, 5->false }), "Iterable tabulate: ``tabulate``");
    assertTrue(deepEquals({ 0, 1, 2 }, chainIterate(5, cTtoI).take(3).do()), "Iterable take");
    assertTrue(deepEquals({ 0, 1, 2 }, chainIterate(5, cTtoI).takeWhile(3.largerThan).do()), "Iterable takeWhile");
}
