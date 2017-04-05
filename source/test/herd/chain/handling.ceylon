import ceylon.test {
    test,
    assertEquals,
    assertTrue,
    assertThatException
}

import herd.chain {
    chain,
    handle
}

shared test void testHandle() {
    assertEquals(1, handle(0, cTtoT).do(), "Handling Chaining callable should be able to start on a positive match");
    assertEquals(null, handle(null, cTtoTN).do(), "Handling Chaining callable should be able to start on a negative match");
}

shared test void testChainHandle() {
    // For callables accepting null types
    assertEquals(2, chain(0, cTtoTN).handle(cTNtoT).do(), "Handling composition should be able to compose on full match (1)");
    assertEquals(0, chain(1, cTtoTN).handle(cTNtoT).do(), "Handling composition should be able to compose on full match (2)");

    assertEquals(0, chain(1, cTtoTN).handle(cNtoI).do(), "Handling composition should be able to compose on a positive match.");
    assertEquals(1, chain(0, cTtoTN).handle(cNtoI).do(), "Handling composition should be able to compose on a negative match.");

    assertThatException(() => chain(1, cTtoTN).handle(cTtoT).do()).hasType(`AssertionError`); //"Handling composition should throw when incomming type can not be cast"
}

shared test void testHandleDemo() {
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
        .handle(handleNullM)                                    // IHandling<Integer|M>
        .handle(mToGorI)                                        // IHandling<Integer|G|[I+]>
        .handle(gToInteger(o))                                  // IHandling<Integer|[I+]>
        .handle(iToInteger)                                     // IHandling<Integer>
        .do();
    assertEquals(ch(false), 1);
    assertEquals(ch(true), 2);
}

shared test void testHandleMethods() {
    //to
    assertEquals(2, handle(0, cTtoT).to(cTtoT).do(), "Handle matchin chained to a simple shain");
    assertEquals(false, handle(false, Integer.even).to(cUtoT).do(), "Handle non-matching chained to a simple chain");

    //spread
    assertEquals([1, false], handle(1, cTtoI).spread(cUItoS).do(), "Handle matching chained to a spread");
    assertEquals([2, true], handle({ 2, 0 }, cTtoI).spread(cUItoS).do(), "Handle non-matching chained to a spread");

    //probe
    assertEquals(3, handle(2, cTtoI).probe(cItoT).do(), "Handle matchin chained to probe");
    assertEquals(1, handle({ 2 }, cTtoI).probe(cItoT).do(), "Handle NON-matchin chained to probe");

    //iterating
    assertTrue(deepEquals({ true, false, true, false }, handle(3, cTtoI).iterate(cItoI).do()), "Handle matching chained to an iterating");
    assertTrue(deepEquals({ 1, 2, 3 }, handle({ 0, 1, 2 }, cTtoI).iterate(({Integer*} ints) => ints.map(Integer.successor)).do()), "Handle non-matching chained to an iterating");
}