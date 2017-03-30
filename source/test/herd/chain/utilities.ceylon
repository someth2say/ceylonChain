/*
 Test callables should hancle three types:
 T -> Unbounded type (i.e. Integer)
 N -> Nullable type (i.e. Integer?)
 S -> Spreadable type (i.e. [Integer,Boolean])
 I -> Iterable type (i.e. {Integer*}
 U -> Union type (i.e. Integer|Boolean)"
*/
Integer(Integer) cTtoT = Integer.successor;
Integer?(Integer) cTtoN = (Integer int) => if (int.even) then int.successor else null;
[Integer, Boolean](Integer) cTtoS = (Integer int) => [int.successor, int.even];

Integer(Integer?) cNtoT = (Integer? int) => if (exists int) then int.successor else 0;
Integer?(Integer?) cNtoN = (Integer? int) => if (exists int) then int.successor else null;
[Integer, Boolean](Integer?) cNtoS = (Integer? int) => if (exists int) then [int.successor, int.even] else [0, true];

Integer(Integer, Boolean) cTTtoT = (Integer int, Boolean b) => if (b) then int.successor else int.predecessor;
Integer?(Integer, Boolean) cTTtoN = (Integer int, Boolean b) => if (b) then int.successor else null;

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

/* Utility methods */
Boolean optEquals(Anything first, Anything second) {
    return if (exists first, exists second) then first.equals(second) else (!first exists&& !second exists);
}

Boolean deepEquals({Anything*} it1, {Anything*} it2) {
    value sameSize = it1.size == it2.size;
    return (it1.empty && it2.empty) || sameSize &&optEquals(it1.first, it2.first) &&deepEquals(it1.rest, it2.rest);
}

