/*
 Test callables should hancle three types:
 T -> Unbounded type (i.e. Integer)
 N -> Nullable type (i.e. Integer?)
 S -> Spreadable type (i.e. *Integer)
 I -> Iterable type (i.e. {Integer*}"
*/
Integer(Integer) cTtoT = Integer.successor;
Integer?(Integer) cTtoN = (Integer int) => if (int.even) then int.successor else null;
[Integer, Boolean](Integer) cTtoS = (Integer int) => [int.successor, int.even];

Integer(Integer?) cNtoT = (Integer? int) => if (exists int) then int.successor else 0;
Integer?(Integer?) cNtoN = (Integer? int) => if (exists int) then int.successor else null;
[Integer, Boolean](Integer?) cNtoS = (Integer? int) => if (exists int) then [int.successor, int.even] else [0, true];

Integer(Integer, Boolean) cStoT = (Integer int, Boolean b) => if (b) then int.successor else int.predecessor;
Integer?(Integer, Boolean) cStoN = (Integer int, Boolean b) => if (b) then int.successor else null;

[Integer, Boolean](Integer, Boolean) cStoS = (Integer int, Boolean b) => if (b) then [int.successor, b] else [int.successor, b];

{Integer*}(Integer) cTtoI = (Integer int) => { int.successor, int.predecessor };


/* Utility methods */
Boolean optionalEquals(Anything first, Anything second) => if (exists first, exists second) then first.equals(second) else (!first exists&& !second exists);
Boolean iterableEquals({Anything*} it1, {Anything*} it2) => it1.empty && it2.empty || it1.size == it2.size &&optionalEquals(it1.first, it2.first) &&iterableEquals(it1.rest, it2.rest);
