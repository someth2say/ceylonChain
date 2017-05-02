import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    chain,
    Chain,
    strip,
    strips,
    StrippedChain
}

shared test void testStrip() {
    assertEquals(1, strip<Integer,Null,Integer>(0, cTtoTN).do(), "Stripping Chaining callable should be able to start on callables accepting null");
    assertEquals(null, strip<Integer,Null,Integer>(1, cTtoTN).do(), "Stripping Chaining callable should be able to start on callables accepting null");

    assertEquals(1, strip<Integer,Null,Integer>(0, cTtoTN).rTo(cNtoT).do(), "Stripping Chaining callable should be able to start on callables accepting null");
    assertEquals(0, strip<Integer,Null,Integer>(1, cTtoTN).rTo(cNtoT).do(), "Stripping Chaining callable should be able to start on callables accepting null");

    assertEquals("1", strip<Integer,Null,Integer>(0, cTtoTN).lTo(Integer.string).do(), "Stripping Chaining callable should be able to start on callables accepting null");
    assertEquals(null, strip<Integer,Null,Integer>(1, cTtoTN).lTo(Integer.string).do(), "Stripping Chaining callable should be able to start on callables accepting null");

    assertEquals(2, strips<Integer,Null,[Integer, Boolean]>([1, true], cTBtoTN).do(), "Stripping Chaining callable should be able to start on callables accepting null");
    assertEquals(null, strips<Integer,Null,[Integer, Boolean]>([1, false], cTBtoTN).do(), "Stripping Chaining callable should be able to start on callables accepting null");
}

shared test void testChainStrip() {
    // For callables accepting null types
    assertEquals(null, chain(0, cTtoT).strip<Integer,Null>(cTtoTN).do(), "Stripping chain should invoke like a basic chain (1)");
    assertEquals(3, chain(1, cTtoT).strip<Integer,Null>(cTtoTN).do(), "Stripping chain should invoke like a basic chain (2)");

    StrippedChain<Null,String> r3 = chain(0, cTtoT).strip<Null,Integer>(cTtoTN).rTo(Integer.string);
    assertEquals(null, r3.do(), "Stripping chain Keep type should be retain, and Handled type should be changed (1)");
    Chain<String?> r4 = chain(1, cTtoT).strip<Null,Integer>(cTtoTN).rTo(Integer.string);
    assertEquals("3", r4.do(), "Stripping chain Keep type should be retain, and Handled type should be changed (2)");

    Chain<Integer> r5 = chain(0, cTtoT).strip<Null,Integer>(cTtoTN).lTo(cNtoT);
    assertEquals(0, r5.do(), "Stripping chain should colapse types when Handled type is transformed to Keep (1)");
    StrippedChain<Integer,Integer> r6 = chain(1, cTtoT).strip<Null,Integer>(cTtoTN).lTo(cNtoT);
    assertEquals(3, r6.do(), "Stripping chain should colapse types when Handled type is transformed to Keep (2)");

    assertEquals(0, chain(0, cTtoT).strip<Null,Integer>(cTtoTN).lrTo(cNtoT, Integer.string).do(),"Stripping chain on both sides (1)");
    assertEquals("3", chain(1, cTtoT).strip<Null,Integer>(cTtoTN).lrTo(cNtoT, Integer.string).do(),"Stripping chain on both sides (2)");

}
