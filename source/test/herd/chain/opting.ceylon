import ceylon.test {
    test,
    assertEquals,
    assertTrue,
    assertThatException
}

import herd.chain {
    chain,
    opt
}

shared test void testHandle() {
    assertEquals(1, opt(0, cTtoT).do(), "Handling Chaining callable should be able to start on a positive match");
    assertEquals(null, opt(null, cTtoTN).do(), "Handling Chaining callable should be able to start on a negative match");
}

shared test void testChainOpt() {
    // For callables accepting null types
    assertEquals(2, chain(0, cTtoTN).opt(cTNtoT).do(), "Handling composition should be able to compose on full match (1)");
    assertEquals(0, chain(1, cTtoTN).opt(cTNtoT).do(), "Handling composition should be able to compose on full match (2)");

    assertEquals(0, chain(1, cTtoTN).opt(cNtoI).do(), "Handling composition should be able to compose on a positive match.");
    assertEquals(1, chain(0, cTtoTN).opt(cNtoI).do(), "Handling composition should be able to compose on a negative match.");

    assertThatException(() => chain(1, cTtoTN).opt(cTtoT).do()).hasType(`AssertionError`); //"Handling composition should throw when incomming type can not be cast"
}

shared test void testOptDemo() {
    class O(shared Boolean b) {}
    class M() {}
    class G() {}
    class I() {}

    M? loadM(O o) => o.b then M() else null;
    Integer|M handleNullM(Null null) => 1;
    Integer|G|[I+] mToGorI(M mod) => 2;
    Integer|[I+] gToInteger(O options)(G gdb) => 3;
    Integer iToInteger([I+] gdb) => 4;

    Integer ch(Boolean b)=> let (o=O(b))
        chain(o, loadM)                                         // IChaining<Null|M>,
        .opt(handleNullM)                                    // IOpting<Integer|M>
        .opt(mToGorI)                                        // IOpting<Integer|G|[I+]>
        .opt(gToInteger(o))                                  // IOpting<Integer|[I+]>
        .opt(iToInteger)                                     // IOpting<Integer>
        .do();
    assertEquals(ch(false), 1);
    assertEquals(ch(true), 2);
}

shared test void testOptMethods() {
    //to
    assertEquals(2, opt(0, cTtoT).to(cTtoT).do(), "Handle matchin chained to a simple shain");
    assertEquals(false, opt(false, Integer.even).to(cUtoT).do(), "Handle non-matching chained to a simple chain");

    //spread
    assertEquals([1, false], opt(1, cTtoI).spread(cUItoS).do(), "Handle matching chained to a spread");
    assertEquals([2, true], opt({ 2, 0 }, cTtoI).spread(cUItoS).do(), "Handle non-matching chained to a spread");

    //probe
    assertEquals(3, opt(2, cTtoI).probe(cItoT).do(), "Handle matchin chained to probe");
    assertEquals(1, opt({ 2 }, cTtoI).probe(cItoT).do(), "Handle NON-matchin chained to probe");

    //iterating
    assertTrue(deepEquals({ true, false, true, false }, opt(3, cTtoI).iterate(cItoI).do()), "Handle matching chained to an iterating");
    assertTrue(deepEquals({ 1, 2, 3 }, opt({ 0, 1, 2 }, cTtoI).iterate(({Integer*} ints) => ints.map(Integer.successor)).do()), "Handle non-matching chained to an iterating");
}