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
    assertEquals(strip<Integer,Null,Integer>(0, cTtoTN).do(), 1, "Stripping Chaining start should invoke like a basic chain (1)");
    assertEquals(strip<Integer,Null,Integer>(1, cTtoTN).do(), null, "Stripping Chaining start should invoke like a basic chain (2)");

    assertEquals(strip<Integer,Null,Integer>(0, cTtoTN).rTo(cNtoT).do(), 1, "Stripping Chaining start on right type (1)");
    assertEquals(strip<Integer,Null,Integer>(1, cTtoTN).rTo(cNtoT).do(), 0, "Stripping Chaining start on right type (2)");

    assertEquals(strip<Integer,Null,Integer>(0, cTtoTN).lTo(Integer.string).do(), "1", "Stripping Chaining start on left type (1)");
    assertEquals(strip<Integer,Null,Integer>(1, cTtoTN).lTo(Integer.string).do(), null, "Stripping Chaining start on left type (2)");

    assertEquals(strips<Integer,Null,[Integer, Boolean]>([1, true], cTBtoTN).do(), 2, "Stripping Chaining start on both types (1)");
    assertEquals(strips<Integer,Null,[Integer, Boolean]>([1, false], cTBtoTN).do(), null, "Stripping Chaining start on both types (2)");
}

shared test void testChainStrip() {
    assertEquals(chain(0, cTtoT).strip<Integer,Null>(cTtoTN).do(), null, "Stripping chain should invoke like a basic chain (1)");
    assertEquals(chain(1, cTtoT).strip<Integer,Null>(cTtoTN).do(), 3, "Stripping chain should invoke like a basic chain (2)");

    StrippedChain<Null,String> r3 = chain(0, cTtoT).strip<Null,Integer>(cTtoTN).rTo(Integer.string);
    assertEquals(r3.do(), null, "Stripping chain Left type should be retain, and Right type should be changed (1)");
    Chain<String?> r4 = chain(1, cTtoT).strip<Null,Integer>(cTtoTN).rTo(Integer.string);
    assertEquals(r4.do(), "3", "Stripping chain Left type should be retain, and Right type should be changed (2)");

    Chain<Integer> r5 = chain(0, cTtoT).strip<Null,Integer>(cTtoTN).lTo(cNtoT);
    assertEquals(r5.do(), 0, "Stripping chain Right type should be retain, and Left type should be changed (1)");
    StrippedChain<Integer,Integer> r6 = chain(1, cTtoT).strip<Null,Integer>(cTtoTN).lTo(cNtoT);
    assertEquals(r6.do(), 3, "Stripping chain Right type should be retain, and Left type should be changed (2)");

    assertEquals(chain(0, cTtoT).strip<Null,Integer>(cTtoTN).lrTo(cNtoT, Integer.string).do(), 0,"Stripping chain on both sides (1)");
    assertEquals(chain(1, cTtoT).strip<Null,Integer>(cTtoTN).lrTo(cNtoT, Integer.string).do(), "3","Stripping chain on both sides (2)");

    assertEquals(chain(2, cTtoT).strip<Null,Integer>(cTtoTN).to(cTNtoT).do(),0,"Stripping chain allows basic chaining (1)");
    assertEquals(chain(1, cTtoT).strip<Null,Integer>(cTtoTN).to(cTNtoT).do(),4,"Stripping chain allows basic chaining (1)");
}
