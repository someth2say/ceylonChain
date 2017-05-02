import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    ifExists,
    ifExistss
}

shared test void testNullSkip() {
    Integer? notNull = 0;
    Integer? isNull = null;
    assertEquals(ifExists(notNull, cTtoT).do(), 1, "NullSafe start passing a matching not-null parameter");
    assertEquals(ifExists(isNull, cTtoT).do(), null, "NullSafe start passing a non-matching null parameter");
    assertEquals(ifExists(isNull, cTNtoT).do(), null, "NullSafe start passing a matching null parameter");

    [Integer,Boolean]? notNullS = [0,true];
    [Integer,Boolean]? isNullS = null;

    assertEquals(ifExistss(notNullS, cTTtoT).do(), 1, "NullSafe start passing a matching not-null parameter");
    assertEquals(ifExistss(isNullS, cTTtoT).do(), null, "NullSafe start passing a non-matching null parameter");
    //This one just makes no sense. No functions accept a parameter list or null!
    //assertEquals(null, ifExistss(isNullS, cTTNtoT).do(), "NullSafe start passing a matching null parameter");
}
