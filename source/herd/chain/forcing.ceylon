"Chain step that only will invoke the associated function if incomming type is applicable. Else, the incoming type pass by.
  <pre>
    value val1 = method1(initialValue);
    value val2 = if (is Method2ParameterType val1) then method2(val1) else val1;
    assert(is ForcedType val2);
    ...
 </pre>

 If the incoming type is assignable to this chain step's function, then function is used, and its return value is forwarded.
 If the incomming type is *NOT* assignable, then the incomming value is returned.
 In both cases, before returning, return value is *asserted* to satisfy the **forced return type**.

 If so, the incomming value is returned, else [[AssertionError]] is thrown.

 The **Forced return type** can be provided by the developer, so forcing steps are actually allowing the developer to control the outgoing (return) type.

 [[ForcingChain]] is the evolution for [[ProbingChain]], adding the capability to control (restrict) the output type.

 Actually, there are three ways to use [[ForcingChain]], each one behaving differently:
 - Without type parameters (letting type inference to provide them):
 [[Chain]] then behaves like asserting the input parameter type to be either the function parameter type or the function return type.
 <pre>
    [[Chain]]<String> f = [[force]](0, Integer.string); // returns \"0\"
    [[Chain]]<String> f = [[force]](\"unknown\", Integer.string); // returns \"unknown\"
    [[Chain]]<String> f = [[force]](null, Integer.string); // Throws an assertion error.
 </pre>

 - With all type parameters set *but* the *forced return type*:
 [[ForcingChain]] then behaves like [[ProbingChain]], forwarding types that can not be handling, and never throwing. Return type is not controled.
 <pre>
    [[Chain]]<Integer|Null> f = [[force]]<Integer,Null,Integer|Null>(null, cNtoT); // returns 0
    [[Chain]]<Integer|Null> f = [[force]]<Integer,Null,Integer|Null>(2, cNtoT); // returns 2
    [[Chain]]<Integer|Null|String> f = [[force]]<Integer,Null,Integer|Null|String>(\"Three\", cNtoT); // returns \"Three\"
    [[Chain]]<...> f = [[force]]<Integer,Null,Integer|Null>(\"Three\", cNtoT); // // Throws an assertion error
 </pre>
 - With all type parameters set:
 [[ForcingChain]] then behaves like [[ProbingChain]], but with type asserting.
 Following sample forces the chain to _accept_ `Integer|String|Null`, and to return just `Integer` or fail.
 <pre>
    [[Chain]]<String> f = [[force]]<Integer,Null,Integer|String|Null,Integer>(null, (Null n) => 0); // returns 0.
    [[Chain]]<String> f = [[force]]<Integer,Null,Integer|String|Null,Integer>(3, (Null n) => 0); // returns 3.
    [[Chain]]<...> f = [[force]]<Integer,Null,Integer|String|Null,Integer>(\"Three\", (Null n) => 0); // Throws an assertion error
 </pre>

 Example: Null value handling
 <pre>
    Integer? foo(Integer i) => if (i.even) then i else null;
    String baz(Integer i) => i.string; // Here the main reason for probing/forcing: `baz` can not accept `Null`
    [[Chain]]<String> forced = [[chain]](2, foo).[[force]](baz); // Force downcasts the incomming `Integer?` to just `String`
    [[Chain]]<String|Null|Integer> probed = [[chain]](2, foo).[[probe]](baz); // Probe keeps the incomming type, so returns `String|Integer?`

    assertEquals(forced.[[do]](), \"2\");
    assertEquals(probed.[[do]](), \"2\"); //Both return same result, despite their types are different.

    assertThatException([[chain]](3, foo).[[force]](baz).do).hasType(`AssertionError`); // This will raise and AssertionException!
    assertEquals([[chain]](3, foo).[[probe]](baz).[[do]](), null); // This will just return 'null'

    [[Chain]]<String|Null> typedForced = [[chain]](3, foo).[[force]]<String,Integer,String|Null>(baz); // But if you force the return type to include null...
    assertEquals(typedForced.[[do]](), null);  //... it gets back to work,

    [[Chain]]<String|Null> typedForced2 = [[chain]](2, foo).[[force]]<String,Integer,String|Null>(baz); // And you don't have to worry about the incomming type
    assertEquals(typedForced2.[[do]](), \"2\");
 </pre>

 Example: Exception handling
 <pre>
    // Exception handling (continue chain with default values)
    Integer handleException(ParseException ex) { print(ex.message); return 0; }
    assertEquals([[chain]](\"2\",Integer.parse).[[force]](handleException).to(Integer.successor).[[do]](),3); // parse suceeds, so handleException does nothing.
    assertEquals([[chain]](\"three\",Integer.parse).[[force]](handleException).to(Integer.successor).[[do]](),1); // parse returns an exception, handled by `handleException`, that prints and chains 0 to next step

    // Exception passing (forward exception to next chain steps)
    assertEquals([[chain]](\"3\",Integer.parse).[[force]]<Integer,Integer,Integer|ParseException>(Integer.successor).[[do]](),4); // No exception...
    assertTrue([[chain]](\"three\",Integer.parse).[[force]]<Integer,Integer,Integer|ParseException>(Integer.successor).[[do]]() is ParseException); // Exception is forwarded
 </pre>"
shared interface ForcingChain<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    see (`function package.force`, `function package.forces`)
    shared Chain<ForcedReturn> force<FuncReturn, FuncArgs, ForcedReturn=Return|FuncReturn>(FuncReturn(FuncArgs) newFunc)
            given FuncReturn satisfies ForcedReturn
            => Forcing<FuncReturn,Return,FuncArgs,ForcedReturn>(this, newFunc);
}

class Forcing<FuncReturn, Return, FuncArgs, ForcedReturn=Return|FuncReturn>(IInvocable<Return> prev, FuncReturn(FuncArgs) func)
        satisfies Chain<ForcedReturn>
        given FuncReturn satisfies ForcedReturn
{
    "If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    shared actual ForcedReturn do() {
        value prevResult = prev.do();
        FuncReturn|Return result = if (is FuncArgs prevResult) then func(prevResult) else prevResult;
        assert (is ForcedReturn result);
        return result;
    }
}

"Initial Handling step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Use with caution."
shared Chain<ForcedReturn> force<FuncReturn, FuncArgs, Arguments, ForcedReturn=Arguments|FuncReturn>(Arguments arguments, FuncReturn(FuncArgs) func)
        given FuncReturn satisfies ForcedReturn
        => object satisfies Chain<ForcedReturn> {
    shared actual ForcedReturn do() {
        FuncReturn|Arguments result = if (is FuncArgs arguments) then func(arguments) else arguments;
        assert (is ForcedReturn result);
        return result;
    }
};

"Initial Handling step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Difference with [[force]] is that this chain requires arguments to be a tuple, that will try to be spread into current function.
 Use with caution."
shared Chain<ForcedReturn> forces<FuncReturn, FuncArgs, Arguments, ForcedReturn=Arguments|FuncReturn>(Arguments arguments, FuncReturn(*FuncArgs) func)
        given FuncReturn satisfies ForcedReturn
        given FuncArgs satisfies Anything[]
        => object satisfies Chain<ForcedReturn> {
    shared actual ForcedReturn do() {
        FuncReturn|Arguments result = if (is FuncArgs arguments) then func(*arguments) else arguments;
        assert (is ForcedReturn result);
        return result;
    }
};
