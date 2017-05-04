import ceylon.test {
    test,
    assertEquals,
    assertTrue
}

import herd.chain {
    chainTo,
    Chain,
    chainStrip,
    StrippedChain,
    chain
}
import ceylon.language.meta.model {
    ClassOrInterface
}

shared test void testStrip() {
    assertEquals(chainStrip<Integer,Null,Integer>(0, cTtoTN).do(), 1, "Stripping Chaining start should invoke like a basic chain (1)");
    assertEquals(chainStrip<Integer,Null,Integer>(1, cTtoTN).do(), null, "Stripping Chaining start should invoke like a basic chain (2)");

    assertEquals(chainStrip<Integer,Null,Integer>(0, cTtoTN).rTo(cNtoT).do(), 1, "Stripping Chaining start on right type (1)");
    assertEquals(chainStrip<Integer,Null,Integer>(1, cTtoTN).rTo(cNtoT).do(), 0, "Stripping Chaining start on right type (2)");

    assertEquals(chainStrip<Integer,Null,Integer>(0, cTtoTN).lTo(Integer.string).do(), "1", "Stripping Chaining start on left type (1)");
    assertEquals(chainStrip<Integer,Null,Integer>(1, cTtoTN).lTo(Integer.string).do(), null, "Stripping Chaining start on left type (2)");

    assertEquals(chainStrip<Integer,Null,Integer>(0, cTtoTN).lrTo(Integer.string, cNtoT).do(), "1", "Stripping Chaining start on both types (1)");
    assertEquals(chainStrip<Integer,Null,Integer>(1, cTtoTN).lrTo(Integer.string, cNtoT).do(), 0, "Stripping Chaining start on both types (2)");
}

shared test void testSample(){
    assertEquals(chain("1").strip<Integer,ParseException>(Integer.parse).lTo(Integer.successor).do(),2);
    Integer|ParseException do = chain("one").strip<Integer,ParseException>(Integer.parse).lTo(Integer.successor).do();
    assertIs(do, `ParseException`);
}

"Fails the test if the given value does not satisfy the provided ClassOrInterface"
throws (`class AssertionError`, "When _actual_ == _unexpected_.")
shared void assertIs(
        "The actual value to be checked."
        Anything val,
        "The class or interface to be satisfied."
        ClassOrInterface<> coi,
        "The message describing the problem."
        String? message = null){
    if (!coi.typeOf(val)){
        throw AssertionError("``message else "assertion failed:"`` expected type not satisfied. expected <``coi``>");
    }
}

shared test void testChainStrip() {
    assertEquals(chainTo(0, cTtoT).strip<Integer,Null>(cTtoTN).do(), null, "Stripping chain should invoke like a basic chain (1)");
    assertEquals(chainTo(1, cTtoT).strip<Integer,Null>(cTtoTN).do(), 3, "Stripping chain should invoke like a basic chain (2)");

    StrippedChain<Null,String> r3 = chainTo(0, cTtoT).strip<Null,Integer>(cTtoTN).rTo(Integer.string);
    assertEquals(r3.do(), null, "Stripping chain Left type should be retain, and Right type should be changed (1)");
    Chain<String?> r4 = chainTo(1, cTtoT).strip<Null,Integer>(cTtoTN).rTo(Integer.string);
    assertEquals(r4.do(), "3", "Stripping chain Left type should be retain, and Right type should be changed (2)");

    Chain<Integer> r5 = chainTo(0, cTtoT).strip<Null,Integer>(cTtoTN).lTo(cNtoT);
    assertEquals(r5.do(), 0, "Stripping chain Right type should be retain, and Left type should be changed (1)");
    StrippedChain<Integer,Integer> r6 = chainTo(1, cTtoT).strip<Null,Integer>(cTtoTN).lTo(cNtoT);
    assertEquals(r6.do(), 3, "Stripping chain Right type should be retain, and Left type should be changed (2)");

    assertEquals(chainTo(0, cTtoT).strip<Null,Integer>(cTtoTN).lrTo(cNtoT, Integer.string).do(), 0,"Stripping chain on both sides (1)");
    assertEquals(chainTo(1, cTtoT).strip<Null,Integer>(cTtoTN).lrTo(cNtoT, Integer.string).do(), "3","Stripping chain on both sides (2)");

    assertEquals(chainTo(2, cTtoT).strip<Null,Integer>(cTtoTN).to(cTNtoT).do(),0,"Stripping chain allows basic chaining (1)");
    assertEquals(chainTo(1, cTtoT).strip<Null,Integer>(cTtoTN).to(cTNtoT).do(),4,"Stripping chain allows basic chaining (1)");
}
