import ceylon.test {
    test,
    assertEquals,
    assertTrue,
    assertThatException
}

import herd.chain {
    chain,
    force,
    IForcing,
    IChaining,
    IProbing
}

shared test void testForce() {

    // Following behave like 'assert argument is FuncReturn' (maybe someday Arguments|FuncReturn)
    // That one should be "IForcing<Integer|String>, but currently type inference and default type parameters can not be used together
    IForcing<String> forceUntypedMatching = force(0, Integer.string);
    assertEquals("0", forceUntypedMatching.do(), "Forcing start with matching arguments");

    // That one should be "IForcing<Integer|String>, but currently type inference and default type parameters can not be used together
    IForcing<String> forceUntypedNotMatching = force("unknown", Integer.string);
    assertEquals("unknown", forceUntypedNotMatching.do(), "Forcing start with not-matching arguments");

    assertThatException(force(null, Integer.string).do).hasType(`AssertionError`); //Null is not a valid default return type for Integer.string

    // Following behave like "probing"
    IForcing<Integer|String|Null> forceDefaultedMatching = force<Integer,Null,Integer|String|Null>(null, cNtoT);
    assertEquals(0, forceDefaultedMatching.do(), "Forcing start with matching arguments and default return type");

    IForcing<Integer|String|Null> forceDefaultedNotMatching = force<Integer,Null,Integer|String|Null>(2, cNtoT);
    assertEquals(2, forceDefaultedNotMatching.do(), "Forcing start with non-matching arguments and default return type");

    IForcing<Integer|String|Null> forceDefaultedFailing = force<Integer,Null,Integer|String|Null>("Three", cNtoT);
    assertEquals("Three", forceDefaultedFailing.do(), "Forcing start with failing arguments and default return type: forwarding");


    // Following are the actual meaning for 'force': downcasting the return type.
    IForcing<Integer> forceTypedMatching = force<Integer,Null,Integer|String|Null,Integer>(null, cNtoT);
    assertEquals(0, forceTypedMatching.do(), "Forcing start with matching arguments and downcasting result");

    IForcing<Integer> forceTypedNotMatching = force<Integer,Null,Integer|String|Null,Integer>(3, cNtoT);
    assertEquals(3, forceTypedNotMatching.do(), "Forcing start with non-matching arguments and downcasting result");

    IForcing<Integer> forceTypedFailing = force<Integer,Null,Integer|String|Null,Integer>("Three", cNtoT);
    assertThatException(forceTypedFailing.do).hasType(`AssertionError`); //"Three" is not a valid input for the function, nor satisfies the forced type `Integer`

}

shared test void sample1() {
    Integer? foo(Integer i) => if (i.even) then i else null;
    String baz(Integer i) => i.string; // Here the main reason for probing/forcing: `baz` can not accept `Null`
    IForcing<String> forced = chain(2, foo).force(baz); // Force downcasts the incomming `Integer?` to just `String`
    IProbing<String|Null|Integer> probed = chain(2, foo).probe(baz); // Probe keeps the incomming type, so returns `String|Integer?`

    assertEquals(forced.do(), "2");
    assertEquals(probed.do(), "2"); //Both return same result, despite their types are different.

    assertThatException(chain(3, foo).force(baz).do).hasType(`AssertionError`); // This will raise and AssertionException!
    assertEquals(chain(3, foo).probe(baz).do(), null); // This will just return 'null'

    IForcing<String|Null> typedForced = chain(3, foo).force<String,Integer,String|Null>(baz); // But if you force the return type to include null...
    assertEquals(typedForced.do(), null);  //... it gets back to work,

    IForcing<String|Null> typedForced2 = chain(2, foo).force<String,Integer,String|Null>(baz); // And you don't have to worry about the incomming type
    assertEquals(typedForced2.do(), "2");
}


shared test void sample2() {
    // Exception handling (continue chain with default values)
    Integer handleException(ParseException ex) { print(ex.message); return 0; }
    assertEquals(chain("2",Integer.parse).force(handleException).to(Integer.successor).do(),3); // parse suceeds, so handleException does nothing.
    assertEquals(chain("three",Integer.parse).force(handleException).to(Integer.successor).do(),1); // parse returns an exception, handled by `handleException`, that prints and chains 0 to next step

    // Exception passing (forward exception to next chain steps)
    assertEquals(chain("3",Integer.parse).force<Integer,Integer,Integer|ParseException>(Integer.successor).do(),4); // No exception...
    assertTrue(chain("three",Integer.parse).force<Integer,Integer,Integer|ParseException>(Integer.successor).do() is ParseException); // Exception is forwarded

    // Currently, using default type parameters produce a backend error. :(
    //assertEquals(chain("3",Integer.parse).force<Integer,Integer>(Integer.successor).do(),4); // No exception...
    //assertTrue(chain("three",Integer.parse).force<Integer,Integer>(Integer.successor).do() is ParseException); // Exception is forwarded

}


shared test void testChainForce() {
    // For callables accepting null types
    IChaining<Integer?> iChaining = chain(0, cTtoTN);
    IForcing<Integer> force = iChaining.force(cTNtoT);
    assertEquals(2, force.do(), "Forcing composition should be able to compose on full match (1)");
    assertEquals(0, chain(1, cTtoTN).force(cTNtoT).do(), "Forcing composition should be able to compose on full match (2)");

    IForcing<Integer> force2 = chain(1, cTtoTN).force(cNtoT);
    assertEquals(0, force2.do(), "Forcing composition should be able to compose on a positive match.");
    assertEquals(1, iChaining.force(cNtoT).do(), "Forcing composition should be able to compose on a negative match.");

    assertThatException(() => chain(1, cTtoTN).force(cTtoT).do()).hasType(`AssertionError`); //"Forcing composition should throw when incomming type can not be cast"
}

shared test void testForceDemo() {
    class O(shared Boolean b) {}

    class M() {}

    class G() {}

    class I() {}

    M? loadM(O o) => o.b then M() else null;
    Integer handleNullM(Null null) => 1;
    G|[I+] mToGorI(M mod) => G();
    Integer gToInt(O options)(G gdb) => 2;
    Integer iToInt([I+] gdb) => 3;

    Integer ch(Boolean b) => let (o = O(b))
    chain(o, loadM)                                     // IChaining<Null|M>,
        .force<Integer,Null,M|Integer>(handleNullM)            // IForcing<M|Integer>
        .force<G|[I+],M,Integer|G|[I+]>(mToGorI)               // IChaining<G|[I+]|Integer>
        .force<Integer,G,Integer|[I+]>(gToInt(o))      // IForcing<Integer|[I+]>
        .force(iToInt)                                         // IForcing<Integer>
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