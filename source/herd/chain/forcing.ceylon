"Chain step that provides capabilities to invoking based on incomming type.
 This is the type un-safe relative for [[IProbing]].
 That is, these chain steps are able to accept functions whose arguments are not exaclty the return type for the previous step,
 or the type for the initially provided parameter for starting steps (from now on, the incomming type).
 If the incoming type is assignable to the arguments for this chain step's function, then this step will apply the function to the
 incomming value, and return the value returned by that function.
 If the incomming type is *NOT* assignable, then, incomming type will be **asserted** to satisfy the function's return type.
 If so, the incomming value is returned, else [[AssertionError]] is thrown.

 In other words, this chain step will try to handle a sub-type for the incomming type. If the step can not handle the incomming type, it assumes
  the incomming type is 'compatible' with the outcomming type, and tryes to cast the incoming value to the outcomming type.

 All this may sound weird, but works naturally in most cases.

 Example: Null value handling
 <pre>
    Integer? foo(Integer i) => if (i.even) i else null;

    // Standard way to use [[force]]
    Integer baz(Null n) => 0;
    assertEquals(chain(2,foo).force(baz).do(),3); // `baz` can not handle `Integer` returned from `foo`, hence `baz` casts '2' to `Integer`. All good.
    assertEquals(chain(1,foo).force(baz).do(),0); // `baz` can handle `Null` returned from `foo`, hence `baz` returns '0'. All good also.

    // Better don't do this, unless you are willing to face assertion errors.
    Integer bar(Integer i) => i.successor;
    assertEquals(chain(2,foo).force(Integer.successor).do(),3); // `foo` returns 2, that is handled by `successor` then bar return 3
    chain(1,foo).force(Integer.successor).do(); // `foo` return null, but `successor` can not handle `Null`, so `force` tries to cast `null` to `Integer`, thrwowing an assertion error
 </pre>

 Example: Exception handling
 <pre>
    Integer handleException(ParseException ex) { print(ex.description); return 0; }
    assertEquals(chain(\"3\",Integer.parse).force(handleException).to(Integer.successor).do(),4); // No `ParseException` is raised, to
    assertEquals(chain(\"three\",Integer.parse).force(handleException).to(Integer.successor).do(),1) // parse returns an exception, handled by `handleException`, that prints and chains 0 to `successor`

     // Better don't do this, unless you are willing to handle assertion errors.
    chain(\"3\", Integer.parse).force(Integer.successor).do(); // This seems to work ok, but...
    chain(\"Three\", Integer.parse).force(Integer.successor).do(); // `parse` returns a `ParseException`, but that can not be accepted by `succesor`. Then `force` tries to cast `ParseException` to `Integer` (the return type for `successor`), and  throws `AssertionError`.
 </pre>

 As said, [[IForcing]] is the type-unsafe relative for [[IProbing]]. Despite being unsafe, many times it is recommended its usage,
 instead of [[IProbing]]. The reason is that [[IForcing]] actually absorb the handled type, asserting the only type
 outgouing will be the type returned by the chain step function. "
shared interface IForcing<Return>
        satisfies IInvocable<Return>
        & IIterable<Return>
        & IChainable<Return>
        & IForzable<Return>
        & IProbable<Return>
        & ISpreadable<Return>
        & ITeeable<Return>
{}

"Aspect or trait interface that provide Handling capability."
shared interface IForzable<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    see (`function package.force`, `function package.forces`)
    shared default IForcing<FuncReturn> force<FuncReturn, FuncArgs>(FuncReturn(FuncArgs) newFunc)
            => Forcing<FuncReturn,Return,FuncArgs>(this, newFunc);
}

class Forcing<FuncReturn, Return, FuncArgs>(IInvocable<Return> prev, FuncReturn(FuncArgs) func)
        satisfies IForcing<FuncReturn> {
    "If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    shared actual FuncReturn do() {
        value prevResult = prev.do();
        assert (is FuncReturn|FuncArgs prevResult);
        return if (is FuncArgs prevResult) then func(prevResult) else prevResult;
    }
}

"Initial Handling step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Use with caution."
shared IForcing<FuncReturn> force<FuncReturn, FuncArgs, Arguments>(Arguments arguments, FuncReturn(FuncArgs) func)
        => object satisfies IForcing<FuncReturn> {
    shared actual FuncReturn do() {
        assert (is FuncReturn|FuncArgs arguments);
        return if (is FuncArgs arguments) then func(arguments) else arguments;
    }
};

"Initial Handling step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Difference with [[force]] is that this chain requires arguments to be a tuple, that will try to be spread into current function.
 Use with caution."
shared IForcing<FuncReturn> forces<FuncReturn, FuncArgs, Arguments>(Arguments arguments, FuncReturn(*FuncArgs) func)
        given FuncArgs satisfies Anything[]
        => object satisfies IForcing<FuncReturn> {
    shared actual FuncReturn do() {
        assert (is FuncReturn|FuncArgs arguments);
        return if (is FuncArgs arguments) then func(*arguments) else arguments;
    }
};
