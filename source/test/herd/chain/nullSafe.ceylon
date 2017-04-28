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
    assertEquals(1, ifExists(notNull, cTtoT).do(), "NullSafe start passing a matching not-null parameter");
    assertEquals(null, ifExists(isNull, cTtoT).do(), "NullSafe start passing a non-matching null parameter");
    assertEquals(null, ifExists(isNull, cTNtoT).do(), "NullSafe start passing a matching null parameter");

    [Integer,Boolean]? notNullS = [0,true];
    [Integer,Boolean]? isNullS = null;

    assertEquals(1, ifExistss(notNullS, cTTtoT).do(), "NullSafe start passing a matching not-null parameter");
    assertEquals(null, ifExistss(isNullS, cTTtoT).do(), "NullSafe start passing a non-matching null parameter");
    //This one just makes no sense. No functions accept a parameter list or null!
    //assertEquals(null, ifExistss(isNullS, cTTNtoT).do(), "NullSafe start passing a matching null parameter");
}
