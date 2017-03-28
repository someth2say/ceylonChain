"Backward chain step that provides probing capabilities.
 That is, those chain step are able to accept functions whose arguments are not exaclty the return type for the previous step,
 or the type for the initially provided parameter for starting steps (from now on, the incomming type).

 If the incoming type is assignable to the arguments for this chain step's function, then this step will apply the function to the
 incomming value, and return the value returned by that function.
 If the incomming type is *NOT* assignable, then the same incomming value will be returned.

 Example: Null value passing
 <pre>
    Integer? foo(Integer i) => if (i.even) i else null;
    Integer bar(Integer i) => i.successor;

    IBwProbing<Integer?,Integer> sp = bwchain(foo)
    IBwChaining<Integer?,Integer> ch = sp.probe(bar); //Note that 'bar' just accepts Integer, not Integer?
    assertEquals(sp.with(2),3); // foo returns 2, then bar return 3
    assertEquals(sp.with(1),null); // foo returns 'null' that is not accepted by bar, so 'null' just is passed by.
 </pre>

 Example: Exception passing
 <pre>
    Integer handleException(ParseException ex) { print(ex.description); return 0; }
    Integer handleInt(Integer i) => i.successor;

    IBwChaining<Integer|ParseException,String> sp = bwchain(Integer.parse)
    IBwProbing<Integer|ParseException,Integer> he = sp.probe(handleException);
    IBwProbing<Integer|ParseException,Integer> hi = he.probe(handleInt);

    assertEquals(he.with(\"3\"),4); // parse is succesfull, so handleException does not math, but handleInt does
    assertEquals(he.with(\"three\"),1) // parse returns an exception, handled by handleException, that prints and returns 0, that is then matched by handleInt
 </pre>
 Note that probing chain steps will not 'absorb' the actually matched type. This mean that the matched type will keep appearing forward in the chain type paramters (in sample, ParseException).
 Also note that, when using a initial probing chain step (say [[bwprobe]] or [[bwprobes]], the initial 'Argument' type (meaning the type the chain will accept) need not to be exactly the same parameter
 type than the initial function used. Hence, type checker is unable to infer the 'Argument' type, and it should be provided by the developer.

 Example: Probing initial step:
  <pre>
    // Keep in mind signature for bwprobe: bwprobe<FuncArgs, Return, Arguments>(Return(FuncArgs) func)
    bwprobe<String,Integer|ParseException,String>(Integer.parse).with(\"three\"); // Third type argument 'String' can not be inferred, so all three types should be provided.
    bwprobe<String,Integer|ParseException,Integer>(Integer.parse).with(3); // This will compile, but provided argument type (Integer) will never match function argument (String), value '3' will allways be the result.
    bwprobe<String,Integer|ParseException,String>(Integer.parse).with(true); // Will NOT compile, as 'true' is not a valid chain argument (Boolean not assignable to String)
    bwprobe<String,Integer|ParseException,String|Boolean>(Integer.parse).with(true); // WILL compile, but 'true' will never match function arguments, so it will be the return value.
 </pre>

 As you can see, the behaviour for [[bwprobe]] (and hence for [[bwprobes]] is not safe, so their usage is discouraged.
 "
shared interface IBwProbing<Return, Arguments>
        satisfies IBwInvocable<Return|Arguments,Arguments>
        & IBwIterable<Return|Arguments,Arguments>
        & IBwChainable<Return|Arguments,Arguments>
        & IBwProbable<Return|Arguments,Arguments>
        & IBwSpreadable<Return|Arguments,Arguments>
{}

"Aspect or trait interface that provide backward probing capability. "
shared interface IBwProbable<Return, Arguments>
        satisfies IBwInvocable<Return,Arguments> {
    shared default IBwProbing<NewReturn|Return,Arguments> probe<NewReturn, FuncArgs>(NewReturn(FuncArgs) newFunc)
            => BwProbing<NewReturn,Arguments,Return,FuncArgs>(this, newFunc);
}

class BwProbing<NewReturn, Arguments, Return, FuncArgs>(IBwInvocable<Return,Arguments> prev, NewReturn(FuncArgs) func)
        satisfies IBwProbing<NewReturn|Return,Arguments> {
    shared actual NewReturn|Return with(Arguments args) => let (prevResult = prev.with(args)) if (is FuncArgs prevResult) then func(prevResult) else prevResult;
}

//TODO: Initial steps are very lame! TC is unable to determine Arguments, because it is provided by the 'with' method. This forces user to provide all 3 type parameters
// Also, the meaning for Arguments is "allowed types for the 'with' funcion", so most users will just set Arguments=Anything
"Initial probing step for a backward chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
  Usage for [[bwprobe]] and [[bwprobes]] is discouraged, as chain arguments can not be infered, and should be provided by the user.
 "
shared IBwProbing<Return|Arguments,Arguments> bwprobe<FuncArgs, Return, Arguments>(Return(FuncArgs) func)
        => object satisfies IBwProbing<Return|Arguments,Arguments> {
    shared actual Return|Arguments with(Arguments args) => if (is FuncArgs args) then func(args) else args;
};

"Initial probing step for a backward chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
  Difference with [[bwprobe]] is that this chain requires arguments to be a tuple, that will try to be spread into current function.
  Usage for [[bwprobe]] and [[bwprobes]] is discouraged, as chain arguments can not be infered, and should be provided by the user.
 "
shared IBwProbing<Return|Arguments,Arguments> bwprobes<FuncArgs, Return, Arguments>(Return(*FuncArgs) func)
        given Arguments satisfies Anything[]
        given FuncArgs satisfies Anything[]
        => object satisfies IBwProbing<Return|Arguments,Arguments> {
    shared actual Return|Arguments with(Arguments args) => if (is FuncArgs args) then func(*args) else args;
};

