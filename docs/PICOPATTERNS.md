# Software Patterns

I did not found a name for those patterns, so I gave them the name of software *PicoPatterns*.
 - Software Patterns talk about how **classes** interact with each other to solve a big problem.
 - Software MicroPatterns talk about how a **methods** for a single class interact with each other (sometimes in reference to another class) to solve a medium-sized problem.
 - Software PicoPatterns talk about **statements** interact with each other to solve a tiny problem.

# PicoPatterns
Like "standard" patterns, picopatters are repeating code structures, that are known to solve common software problems.
But mean "standard" patterns solve problems about classes and instances, piccopaterns solve problems about statements and functions.
Picopatterns define standard coding problems, and explain how to apply available statements to solve them.

## What are and what are not
- Picopatterns are are intended that solve common statement-level problems.
- Picopatterns are code structures.
- Picopatterns are **not** code-golf: solving common problems with the fewer key strokes.
- Picopatterns are **not** code, libraries nor functions.

## Classification
- Type/Value
Picopatterns may solve their problems by either evaluating only types involved, or by also evaluating the values.
I.e. the following code:
```
    value val1 = ...
    value val2 = if (condition(val1)) then function(val1) else val1;
```
is a value picopattern (the "ifCondition" pattern).
 On the other side, the following:
```
    value val1 = ...
    value val2 = if (val1 is Type1) then function(val1) else val1;
```
is a typepattern (the "ifType" pattern).

Some patterns may differ its classification depending on language features.
This is the case for the "ifExists" pattern:
In Java (like many C-based languages), it is a value pattern:
```
    Type1 val1 = ...
    Type2 val2 = (val1 != null) ? function(val1) : null ;
```
While in Ceylon, it is a type pattern:
```
    Type1? val1 = ...
    Type2? val2 = if (exists val1) then function(val1) else val2;
```

Chain module have its focus on *Type PicoPatterns*. That is, patterns based on function's/variable's type,
as opposed to function/variable's values.

- Simple/Binary/Multiple
Another way of categorizing picopatterns is based on the amount possible paths execution flow may take.

Simple patterns are those where the execution flow is just one, and no branches are present. The "chaining" pattern is the simplest example:
```
    value val1 = ...
    value val2 = function(val1);
```

Binary picopatterns do branch execution flow on a single point, and given a binary option. The `ifCondition` pattern is one canonical example:
```
    value val1 = ...
    value val2 = if (condition(val1))
                    then function(val1)     // First branch or execution flow
                    else val1;              // Second branch or execution flow.
```

Multiple picopatterns extend Binary ones with several other execution flows. The `switchCondition` pattern follows this classification:
```
    value val1 = ...
    value val2 = switch(condition(val1))
                 case (case1) function1(val1)     // First branch or execution flow
                 case (case2) function2(val1)     // Second branch or execution flow.
                    ...
                 default functionDefault(val1)    // Last branch or execution flow.
```

# Picopattern Enumeration
This section describes all patterns identified so far:

# Chaining

# Teeing

# IfCondition

# IfType (Probing)

# ifExists (Null Safe)

# CaseCondition

# CaseType (Stripping)

# Iterating