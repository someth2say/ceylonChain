"Chain step that provides probing capabilities.
 That is, those chain step are able to accept functions whose arguments are not exaclty the return type for the previous step,
 or the type for the initially provided parameter for starting steps (from now on, the incomming type).

 If the incoming type is assignable to the arguments for this chain step's function, then this step will apply the function to the
 incomming value, and return the value returned by that function.
 If the incomming type is *NOT* assignable, then the same incomming value will be returned.

 Example: Null value passing
 <pre>
    Integer? foo(Integer i) => if (i.even) i else null;
    Integer bar(Integer i) => i.successor;

    IProbing<Integer?,Integer> sp = chain(2,foo)
    IChaining<Integer?,Integer> ch = sp.probe(bar); //Note that 'bar' just accepts Integer, not Integer?
    assertEquals(sp.do(),3); // foo returns 2, then bar return 3
    assertEquals(chain(1,foo).probe(bar).do(),null); // foo returns 'null' that is not accepted by bar, so 'null' just is passed by.
 </pre>

 Example: Exception passing
 <pre>
    Integer handleException(ParseException ex) { print(ex.description); return 0; }
    Integer handleInt(Integer i) => i.successor;

    IChaining<Integer|ParseException,String> sp = chain(\"3\",Integer.parse)
    IProbing<Integer|ParseException,Integer> he = sp.probe(handleException);
    IProbing<Integer|ParseException,Integer> hi = he.probe(handleInt);

    assertEquals(he.do(),4); // parse is succesfull, so handleException does not math, but handleInt does
    assertEquals(chain(\"three\",Integer.parse).probe(handleException).probe(handleInt).do(),1) // parse returns an exception, handled by handleException, that prints and returns 0, that is then matched by handleInt
 </pre>
 Note that probing chain steps will not 'absorb' the actually matched type. This mean that the matched type will keep appearing forward in the chain type paramters (in sample, ParseException).

 Behaviour for [[IProbing]] can be very tricky in complex cases (i.e. when return types are complex, or many different paths can be taken.
 Use with caution.
 "
shared interface IShrinking<Return, Arguments>
        satisfies IInvocable<Return>
        & IIterable<Return,Arguments>
        & IChainable<Return,Arguments>
        & IProbable<Return,Arguments>
        & ISpreadable<Return,Arguments>
        & IShrinkable<Return,Arguments>
{}

"Aspect or trait interface that provide probing capability."
shared interface IShrinkable<Return, Arguments>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    see (`function package.probe`, `function package.probes`)
    shared default IShrinking<FuncReturn,Arguments> shrink<FuncReturn, FuncArgs>(FuncReturn(FuncArgs) newFunc)
    //given FuncReturn satisfies Return <-- Cyclic inheritance
    {
        return Shrinking<FuncReturn,Arguments,FuncArgs, Return>(this, newFunc);
    }
}

class Shrinking<FuncReturn, Arguments, FuncArgs, Return>(IInvocable<Return> prev, FuncReturn(FuncArgs) func)
        satisfies IShrinking<FuncReturn,Arguments>
{
    "If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    shared actual FuncReturn do() {
        value prevResult = prev.do();
        assert(is FuncArgs|FuncReturn prevResult);
        return switch (prevResult)
        case (is FuncArgs) func(prevResult)
        else prevResult;
    }
}

"Initial Shrinking step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Use with caution."
shared IShrinking<FuncReturn,Arguments> shrink<FuncReturn, FuncArgs, Arguments>(FuncReturn|FuncArgs arguments, FuncReturn(FuncArgs) func)
// given Arguments satisfies FuncArgs|Return <-- Unsupported
        => object satisfies IShrinking<FuncReturn,Arguments> {
    shared actual FuncReturn do() {
        return switch (arguments)
        case (is FuncArgs) func(arguments)
        else arguments;
    }
};
"Initial Shrinking step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Difference with [[probe]] is that this chain requires arguments to be a tuple, that will try to be spread into current function.
 Use with caution."
shared IShrinking<FuncReturn,Arguments> shrinks<FuncReturn, FuncArgs, Arguments>(FuncReturn|FuncArgs arguments, FuncReturn(*FuncArgs) func)
        given FuncArgs satisfies Anything[]
        => object satisfies IShrinking<FuncReturn,Arguments> {
    shared actual FuncReturn do() {
        return switch (arguments)
        case (is FuncArgs) func(*arguments)
        else arguments;
    }
};
