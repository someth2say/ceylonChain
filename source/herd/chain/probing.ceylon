"Chain step that provides probing capabilities.
  This is the type un-safe relative for [[IHandling]].

 That is, these chain steps are able to accept functions whose arguments are not exaclty the return type for the previous step,
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
shared interface IProbing<Return, Arguments>
        satisfies IInvocable<Return>
        & IIterable<Return,Arguments>
        & IChainable<Return,Arguments>
        & IProbable<Return,Arguments>
        & ISpreadable<Return,Arguments>
        & IHandleable<Return,Arguments>
{}

"Aspect or trait interface that provide probing capability."
shared interface IProbable<Return, Arguments>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    see (`function package.probe`, `function package.probes`)
    shared default IProbing<NewReturn|Return,Arguments> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc)
            => Probing<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
}

class Probing<NewReturn, Arguments, Return, FuncArgs>(IInvocable<Return> prev, NewReturn(FuncArgs) func)
        satisfies IProbing<NewReturn|Return,Arguments> {
    "If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    shared actual NewReturn|Return do() => let (prevResult = prev.do()) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

"Initial probing step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Use with caution."
shared IProbing<Return|Arguments,Arguments> probe<Return, FuncArgs, Arguments>(Arguments arguments, Return(FuncArgs) func)
        => object satisfies IProbing<Return|Arguments,Arguments> {
    shared actual Return|Arguments do() => if (is FuncArgs arguments) then func(arguments) else arguments;
};

"Initial probing step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Difference with [[probe]] is that this chain requires arguments to be a tuple, that will try to be spread into current function.
 Use with caution."
shared IProbing<Return|Arguments,Arguments> probes<Return, FuncArgs, Arguments>(Arguments arguments, Return(*FuncArgs) func)
        given FuncArgs satisfies Anything[]
        => object satisfies IProbing<Return|Arguments,Arguments> {
    shared actual Return|Arguments do() => if (is FuncArgs arguments) then func(*arguments) else arguments;
};
