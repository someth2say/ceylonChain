"Chain step that provides simplest method chaining pattern.
 <pre>
     value val1 = method1(initialValue);
     value val2 = method2(val1);
     value val3 = method3(val2);
     ...
 </pre>

 Basic chaining is mainly performed with the [[to]] method;
 Example:
 <pre>
    [[Chain]]<Integer,String> bwch = [[chainTo]](\"10\",Integer.parse)
    [[Chain]]<Boolean,String> ch = sp.[[to]](Integer.even);
    assertEquals(ch.[[do]](),true);
 </pre>"
shared interface ChainingChain<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by passing the result of the chain so far to a new function.
     The new function MUST accept the return type for the chain so far as its only parameter."
    see (`function package.chainTo`, `function package.chain`)
    shared Chain<NewReturn> to<NewReturn>(NewReturn(Return) newFunc)
            => Chaining<NewReturn,Return>(this, newFunc);
}

class Chaining<Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(PrevReturn) func)
        extends ChainStep<Return,PrevReturn>(prev, func)
        satisfies Chain<Return> {}


"Initial chaining step for a chain, that just allow further chain steps to be added."
shared Chain<Arguments> chain<Arguments>(Arguments arguments)
        => object extends ChainStart<Arguments>(arguments) satisfies Chain<Arguments> {};

"Initial chaining step for a chain, that chains the first function directly.
 It is just a shortcut for `[[chain]](arguments).to(func)`"
shared Chain<Return> chainTo<Return, Arguments>(Arguments arguments, Return(Arguments) func)
        => object extends ChainStartTo<Return,Arguments>(arguments, func)
        satisfies Chain<Return> {};
