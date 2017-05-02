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
    assertEquals(strip<Integer,Null,Integer>(0, cTtoTN).do(), 1, "Stripping Chaining callable should be able to start on callables accepting null");
    assertEquals(strip<Integer,Null,Integer>(1, cTtoTN).do(), null, "Stripping Chaining callable should be able to start on callables accepting null");

    assertEquals(strip<Integer,Null,Integer>(0, cTtoTN).rTo(cNtoT).do(), 1, "Stripping Chaining callable should be able to start on callables accepting null");
    assertEquals(strip<Integer,Null,Integer>(1, cTtoTN).rTo(cNtoT).do(), 0, "Stripping Chaining callable should be able to start on callables accepting null");

    assertEquals(strip<Integer,Null,Integer>(0, cTtoTN).lTo(Integer.string).do(), "1", "Stripping Chaining callable should be able to start on callables accepting null");
    assertEquals(strip<Integer,Null,Integer>(1, cTtoTN).lTo(Integer.string).do(), null, "Stripping Chaining callable should be able to start on callables accepting null");

    assertEquals(strips<Integer,Null,[Integer, Boolean]>([1, true], cTBtoTN).do(), 2, "Stripping Chaining callable should be able to start on callables accepting null");
    assertEquals(strips<Integer,Null,[Integer, Boolean]>([1, false], cTBtoTN).do(), null, "Stripping Chaining callable should be able to start on callables accepting null");
}

shared test void testChainStrip() {
    // For callables accepting null types
    assertEquals(chain(0, cTtoT).strip<Integer,Null>(cTtoTN).do(), null, "Stripping chain should invoke like a basic chain (1)");
    assertEquals(chain(1, cTtoT).strip<Integer,Null>(cTtoTN).do(), 3, "Stripping chain should invoke like a basic chain (2)");

    StrippedChain<Null,String> r3 = chain(0, cTtoT).strip<Null,Integer>(cTtoTN).rTo(Integer.string);
    assertEquals(r3.do(), null, "Stripping chain Keep type should be retain, and Handled type should be changed (1)");
    Chain<String?> r4 = chain(1, cTtoT).strip<Null,Integer>(cTtoTN).rTo(Integer.string);
    assertEquals(r4.do(), "3", "Stripping chain Keep type should be retain, and Handled type should be changed (2)");

    Chain<Integer> r5 = chain(0, cTtoT).strip<Null,Integer>(cTtoTN).lTo(cNtoT);
    assertEquals(r5.do(), 0, "Stripping chain should colapse types when Handled type is transformed to Keep (1)");
    StrippedChain<Integer,Integer> r6 = chain(1, cTtoT).strip<Null,Integer>(cTtoTN).lTo(cNtoT);
    assertEquals(r6.do(), 3, "Stripping chain should colapse types when Handled type is transformed to Keep (2)");

    assertEquals(chain(0, cTtoT).strip<Null,Integer>(cTtoTN).lrTo(cNtoT, Integer.string).do(), 0,"Stripping chain on both sides (1)");
    assertEquals(chain(1, cTtoT).strip<Null,Integer>(cTtoTN).lrTo(cNtoT, Integer.string).do(), "3","Stripping chain on both sides (2)");
}
