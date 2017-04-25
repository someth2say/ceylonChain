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
    [[IChainable]]<Integer,String> bwch = [[chain]](\"10\",Integer.parse)
    [[IChainable]]<Boolean,String> ch = sp.[[to]](Integer.even);
    assertEquals(ch.[[do]](),true);
 </pre>"
shared interface IChainable<Return>
        satisfies IInvocable<Return> {
    "Adds a new step to the chain, by passing the result of the chain so far to a new function.
     The new function MUST accept the return type for the chain so far as its only parameter."
    see( `function package.chain`, `function package.chains`)
    shared Chain<NewReturn> to<NewReturn>(NewReturn(Return) newFunc)
            => Chaining<NewReturn,Return>(this, newFunc);
}

class Chaining<Return, PrevReturn>(IInvocable<PrevReturn> prev, Return(PrevReturn) func)
        extends ChainStep<Return,PrevReturn>(prev, func)
        satisfies Chain<Return> {}

"Initial chaining step for a chain, that just allow further chain steps to be added."
shared Chain<Return> chain<Return, Arguments>(Arguments arguments, Return(Arguments) func)
        => object extends ChainStart<Return,Arguments>(func, arguments)
        satisfies Chain<Return> {};

"Initial chaining step for a  chain, that just allow further chain steps to be added.
  The only difference with [[chain]] is that [[chains]] will accept a tuple as chain arguments, that will be spread into this step's function."
shared Chain<Return> chains<Return, Arguments>(Arguments arguments, Return(*Arguments) func)
        given Arguments satisfies Anything[]
        => object extends SpreadingChainStart<Return,Arguments>(func, arguments)
        satisfies Chain<Return> {};
