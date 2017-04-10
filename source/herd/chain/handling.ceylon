"Chain step that provides Handling capabilities.
 This is the type un-safe relative for [[IProbing]].
 That is, these chain steps are able to accept functions whose arguments are not exaclty the return type for the previous step,
 or the type for the initially provided parameter for starting steps (from now on, the incomming type).
 But instead, this chain step will accept a function that:
  - Accept a **subtype** for the incomming type, and
  - Return a **subtype** for the incomming type

 If the incoming type is assignable to the arguments for this chain step's function, then this step will apply the function to the
 incomming value, and return the value returned by that function.
 If the incomming type is *NOT* assignable, then, incomming type will be **asserted** to satisfy the function's return type.
 If so, the incomming value is returned.

 In other words, this chain step will try to handle a sub-type for the incomming type. If the step can not handle the incomming type, it assumes
  the incomming type is 'compatible' with the outcomming type, and tryes to cast the incoming value to the outcomming type.

 All this may sound weird, but works naturally in most cases.

 Example: Null value passing
 <pre>
    Integer? foo(Integer i) => if (i.even) i else null;

    // Standard way to use [[handle]]
    Integer baz(Null n) => 0;
    assertEquals(chain(2,foo).handle(baz).do(),3); // `baz` can not handle `Integer` as returned from `foo`, hence `baz` casts '2' to `Integer`. All good.
    assertEquals(chain(1,foo).handle(baz).do(),0); //`baz` can handle `Null` as returned from `foo`, hence `baz` returns '0'. All good also.

    // Better don't do this, unless you are willing to handle assertion errors.
    Integer bar(Integer i) => i.successor;
    assertEquals(chain(2,foo).handle(bar).do(),3); // foo returns 2, then bar return 3
    chain(1,foo).handle(bar).do(); //`bar` can not handle `Null`, hence tries to cast `null` to `Integer`, thrwowing an assertion error

 </pre>

 Example: Exception passing
 <pre>

    Integer handleException(ParseException ex) { print(ex.description); return 0; }
    assertEquals(chain(\"3\",Integer.parse).handle(handleException).to(Integer.successor).do(),4); // No `ParseException` is raised, to
    assertEquals(chain(\"three\",Integer.parse).handle(handleException).to(Integer.successor).do(),1) // parse returns an exception, handled by handleException, that prints and returns 0, that is then chained to `successor`

     // Better don't do this, unless you are willing to handle assertion errors.
    chain(\"3\", Integer.parse).handle(Integer.successor).do(); // This seems to work ok, but...
    chain(\"Three\", Integer.parse).handle(Integer.successor).do(); // `parse` returns a `ParseException`, but that can not be accepted by `succesor`. `successor`s return type is `Integer`, so `handle` tryes to cast `ParseException` to `Integer`, and throws.
 </pre>

 As says, [[IHandling]] is the type-unsafe relative for [[IProbing]]. Despite being unsafe, many times it is recommended its ussage, instead of [[IProbing]]. The reason is that [[IHandling]] actually absorb the handled type, asserting the only type
 outgouing will be the type returned by the chain step function. "
shared interface IHandling<Return>
        satisfies IInvocable<Return>
        & IIterable<Return>
        & IChainable<Return>
        & IHandleable<Return>
        & IProbable<Return>
        & ISpreadable<Return>
        & ITeeable<Return>
{}

"Aspect or trait interface that provide Handling capability."
shared interface IHandleable<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by trying to apply result so far to the provided function.
     If function accepts the result type for previous chain step, then this step will return the result
     of applying the function to the previous result.
     If function does not accept the retult type for previous chain step, then this same previous result
     is returned, with no further modification."
    see (`function package.handle`, `function package.handles`)
    shared default IHandling<FuncReturn> handle<FuncReturn, FuncArgs>(FuncReturn(FuncArgs) newFunc)
            => Handling<FuncReturn,Return,FuncArgs>(this, newFunc);
}

class Handling<FuncReturn, Return, FuncArgs>(IInvocable<Return> prev, FuncReturn(FuncArgs) func)
        satisfies IHandling<FuncReturn> {
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
shared IHandling<FuncReturn> handle<FuncReturn, FuncArgs, Arguments>(Arguments arguments, FuncReturn(FuncArgs) func)
        => object satisfies IHandling<FuncReturn> {
    shared actual FuncReturn do() {
        assert (is FuncReturn|FuncArgs arguments);
        return if (is FuncArgs arguments) then func(arguments) else arguments;
    }
};

"Initial Handling step for a chain. It will try to use chain arguments into provided function. If succesfull, will return function result. Else, will return provided arguments.
 Difference with [[handle]] is that this chain requires arguments to be a tuple, that will try to be spread into current function.
 Use with caution."
shared IHandling<FuncReturn> handles<FuncReturn, FuncArgs, Arguments>(Arguments arguments, FuncReturn(*FuncArgs) func)
        given FuncArgs satisfies Anything[]
        => object satisfies IHandling<FuncReturn> {
    shared actual FuncReturn do() {
        assert (is FuncReturn|FuncArgs arguments);
        return if (is FuncArgs arguments) then func(*arguments) else arguments;
    }
};
