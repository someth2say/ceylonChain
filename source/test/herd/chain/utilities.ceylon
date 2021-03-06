import ceylon.language.meta.model {
    ClassOrInterface
}
/*
 Test callables should hancle three types:
 T -> Unbounded type (i.e. Integer)
 N -> Nullable type (i.e. Integer?)
 S -> Spreadable type (i.e. [Integer,Boolean])
 I -> Iterable type (i.e. {Integer*}
 U -> Union type (i.e. Integer|Boolean)"
*/
Integer(Integer) cTtoT = Integer.successor;
Integer?(Integer) cTtoTN = (Integer int) => if (int.even) then int.successor else null;
[Integer, Boolean](Integer) cTtoS = (Integer int) => [int.successor, int.even];

Integer(Integer?) cTNtoT = (Integer? int) => if (exists int) then int.successor else 0;
Integer?(Integer?) cTNtoTN = (Integer? int) => if (exists int) then int.successor else null;
[Integer, Boolean](Integer?) cTNtoS = (Integer? int) => if (exists int) then [int.successor, int.even] else [0, true];

Integer(Integer, Boolean) cTTtoT = (Integer int, Boolean b) => if (b) then int.successor else int.predecessor;
Integer?(Integer, Boolean) cTTtoTN = (Integer int, Boolean b) => if (b) then int.successor else null;

[Integer, Boolean]([Integer, Boolean]) cStoS = ([Integer, Boolean] s) => if (s[1]) then [s[0].successor, s[1]] else [s[0].predecessor, s[1]];
Integer([Integer, Boolean]) cStoT = ([Integer, Boolean] s) => if (s[1]) then s[0].successor else s[0].predecessor;
[Integer, Boolean](Integer, Boolean) cTTtoS = (Integer i, Boolean b) => if (b) then [i.successor, b] else [i.successor, b];

{Integer*}(Integer) cTtoI = (Integer int) => 0..int;
Integer({Integer*}) cItoT = ({Integer*} iter) => iter.size;
[Integer, Boolean]({Integer*}) cItoS = ({Integer*} iter) => [iter.size, iter.contains(0)];
{Boolean*}({Integer*}) cItoI = ({Integer*} iter) => iter.map(Integer.even);

Boolean(Integer|Boolean) cUtoT = (Integer|Boolean iob) => if (is Integer iob) then iob.even else iob;
Integer(Integer|{Integer*}) cUItoT = (Integer|{Integer*} ios) => if (is {Integer*} ios) then Integer.sum(ios) else ios;
[Integer, Boolean](Integer|{Integer*}) cUItoS = (Integer|{Integer*} ios) => let (int = cUItoT(ios)) [int, int.even];
{Integer*}(Integer|{Integer*}) cUItoI = (Integer|{Integer*} ios) => let (int = cUItoT(ios)) { int };

Integer|Null cTBtoTN(Integer i, Boolean b) => if (b) then i.successor else null;

Integer(Null) cNtoT = (Null n) => 0;

suppressWarnings ("expressionTypeNothing")
Nothing(Integer) cTtoV = (Integer int) {
    return process.exit(1);
};

/* Utility methods */
Boolean optEquals(Anything first, Anything second) {
    return if (exists first, exists second) then first.equals(second) else (!first exists&& !second exists);
}

Boolean deepEquals({Anything*} it1, {Anything*} it2) {
    value sameSize = it1.size == it2.size;
    return (isEmpty(it1) && isEmpty(it2)) || sameSize &&optEquals(it1.first, it2.first) &&deepEquals(getRest(it1), getRest(it2));
}

//Keep the following here until https://github.com/ceylon/ceylon/pull/7002 get in with Ceylon 1.3.3
//Else, NPE raises on test
Boolean isEmpty({Anything*} it) {
    return it.shorterThan(1);
}
//Keep the following here until https://github.com/ceylon/ceylon/pull/7002 get in with Ceylon 1.3.3
//Else, test fail
{Anything*} getRest({Anything*} it) {
    return it.skip(1);
}


"Fails the test if the given value does not satisfy the provided ClassOrInterface"
throws (`class AssertionError`, "When _actual_ == _unexpected_.")
shared void assertIs(
        "The actual value to be checked."
        Anything val,
        "The class or interface to be satisfied."
        ClassOrInterface<> coi,
        "The message describing the problem."
        String? message = null) {
    if (!coi.typeOf(val)) {
        throw AssertionError("``message else "assertion failed:"`` expected type not satisfied. expected <``coi``>");
    }
}
