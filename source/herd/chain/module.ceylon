"Module for defining and approach por chaining callables.

 As per proposed in <a href='https://github.com/ceylon/ceylon/issues/6615'> here</a>, fishead operator (`|>`) is
 pretty useful for expressing a list of operations that follow the chain pattern:
 <pre>
    value init = ...;
    value step1 = func1(init);
    value step2 = func2(step1);
    ...
    value stepN = funcN(stepN-1);
 </pre>
 Without fishead operator, those can just be rewritten like:
 <pre>
     funcN(...func2(fun1(init))...).
 </pre>
 But this is strongly unclear as A) it reverses the order of operations, and B) it add a lot of seamless parens.
 So, while fishead operators family is not available, it can be simulated with this library.
 <pre>
    chain(init, step1).to(step2)...to(stepN).do().
 </pre>"
by ("Jordi Sola")
module herd.chain "1.2.0" {}
