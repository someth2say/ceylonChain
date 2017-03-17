shared Result(Third)(First)(Second) lastParamToFirst<Result, First, Second, Third>(Result(First)(Second)(Third) func) => (Second s)(First f)(Third t) => func(t)(s)(f);

shared Result identityEach<Result, Item>(Anything(Item) step)(Result iterable) given Result satisfies {Item*} {
    iterable.each(step);
    return iterable;
}
