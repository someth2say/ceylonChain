import ceylon.test {
    test,
    assertEquals,
    assertTrue,
    assertThatException
}

import herd.chain {
    chain,
    force
}

shared test void testForce() {
    assertEquals(1, force(0, cTtoT).do(), "Forcing Chaining callable should be able to start on a positive match");
    assertEquals(null, force(null, cTtoTN).do(), "Forcing Chaining callable should be able to start on a negative match");
}

shared test void testChainForce() {
    // For callables accepting null types
    assertEquals(2, chain(0, cTtoTN).force(cTNtoT).do(), "Forcing composition should be able to compose on full match (1)");
    assertEquals(0, chain(1, cTtoTN).force(cTNtoT).do(), "Forcing composition should be able to compose on full match (2)");

    assertEquals(0, chain(1, cTtoTN).force(cNtoI).do(), "Forcing composition should be able to compose on a positive match.");
    assertEquals(1, chain(0, cTtoTN).force(cNtoI).do(), "Forcing composition should be able to compose on a negative match.");

    assertThatException(() => chain(1, cTtoTN).force(cTtoT).do()).hasType(`AssertionError`); //"Forcing composition should throw when incomming type can not be cast"
}

shared test void testForceDemo() {
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
        .force(handleNullM)                                    // IForcing<Integer|M>
        .force(mToGorI)                                        // IForcing<Integer|G|[I+]>
        .force(gToInteger(o))                                  // IForcing<Integer|[I+]>
        .force(iToInteger)                                     // IForcing<Integer>
        .do();
    assertEquals(ch(false), 1);
    assertEquals(ch(true), 2);
}

shared test void testForceMethods() {
    //to
    assertEquals(2, force(0, cTtoT).to(cTtoT).do(), "Force matchin chained to a simple shain");
    assertEquals(false, force(false, Integer.even).to(cUtoT).do(), "Force non-matching chained to a simple chain");

    //spread
    assertEquals([1, false], force(1, cTtoI).spread(cUItoS).do(), "Force matching chained to a spread");
    assertEquals([2, true], force({ 2, 0 }, cTtoI).spread(cUItoS).do(), "Force non-matching chained to a spread");

    //probe
    assertEquals(3, force(2, cTtoI).probe(cItoT).do(), "Force matchin chained to probe");
    assertEquals(1, force({ 2 }, cTtoI).probe(cItoT).do(), "Force NON-matchin chained to probe");

    //iterating
    assertTrue(deepEquals({ true, false, true, false }, force(3, cTtoI).iterate(cItoI).do()), "Force matching chained to an iterating");
    assertTrue(deepEquals({ 1, 2, 3 }, force({ 0, 1, 2 }, cTtoI).iterate(({Integer*} ints) => ints.map(Integer.successor)).do()), "Force non-matching chained to an iterating");
}