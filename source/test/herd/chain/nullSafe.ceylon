import ceylon.test {
    test,
    assertEquals
}

import herd.chain {
    ifExists
}

shared test void testNullSafe() {
    Integer? notNull = 0;
    Integer? isNull = null;
    assertEquals(ifExists(notNull, cTtoT).do(), 1, "NullSafe start passing a matching not-null parameter");
    assertEquals(ifExists(isNull, cTtoT).do(), null, "NullSafe start passing a non-matching null parameter");
    assertEquals(ifExists(isNull, cTNtoT).do(), null, "NullSafe start passing a matching null parameter");
}
