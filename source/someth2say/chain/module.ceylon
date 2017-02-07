"Module for defining and approach por chaining callables.
 As per proposed in https://github.com/ceylon/ceylon/issues/6615, headfish operator `|>` is
 pretty useful for expressing a set of operations that follow the chain pattern:
    value init = ...;
    value step1 = func1(init);
    value step2 = func2(step1);
    ...
    value stepN = funcN(stepN-1);
 For sure, those can be rewritten like:
     funcN(...func2(fun1(init))...).
 But this is clearly unclear as A) it reverses the order of operations, and B) it add a lot of seamless parens.
 So, while headfish operators family is not available, it can be simulated with this library.

    chain(step1).andThen(step2)...andThen(stepN).with(init).

 Note that this design have some caveats, mainly compared to the headfish operator:
    - It have a minumum memory footprint.
    - It can't trypesafelly represent the Dead-Headfish operator `|*>`
 "
module someth2say.chain "1.1.0" {}
