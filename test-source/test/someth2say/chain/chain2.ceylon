import ceylon.test {
    test,
    assertEquals
}
import someth2say.chain {
    chain2,
    chainSpread,
    IChainable
}

Integer(String) stringSizeCallable2 = String.size;
IChainable<Integer,String> stringSizeChain2 = chain2<Integer,String>(stringSizeCallable2);
String helloMessage2 = "Hello Ceylon";
String byeMessage2 = "ByeBye Ceylon";
Integer?(Integer) evenOrNullCallable2 => (Integer num) => if (num.even) then num else null;

shared test void invocation2() {
    // Chain start and parameter setting
    assertEquals(stringSizeChain2.with(helloMessage2), stringSizeCallable2(helloMessage2), "Invoking a ChainStart should directly invoke the method on the params"); //12
}

shared test void composition2() {
    value integerEvenCallable2 = Integer.even;
    value printStringSizeEven2 = stringSizeChain2.chain(integerEvenCallable2);

    assertEquals(printStringSizeEven2.with(helloMessage2), integerEvenCallable2(stringSizeCallable2(helloMessage2)), "Chained callables should be equivalent to invonking those callables in the opposing order."); // true
    assertEquals(printStringSizeEven2.with(byeMessage2), integerEvenCallable2(stringSizeCallable2(byeMessage2)), "Chained callables should be equivalent to invonking those callables in the opposing order."); // false
}

shared test void conditionalComposition2() {
    IChainable<Integer?,Integer> evenOrNull = chain2(evenOrNullCallable2);
    Integer(Integer) successor = Integer.successor ;
    value successorIfEvenChain2 = evenOrNull.chainOptional(successor);
    assertEquals(successorIfEvenChain2.with(0), 1, "Not null values in conditional composition should behave like normal composition.");
    assertEquals(successorIfEvenChain2.with(1), null, "Null should be spread to the right with conditional composition.");
}

shared test void spreadingComposition2() {

    Integer(Integer, Boolean) multipleParametersCallable2 = (Integer one, Boolean other) => if (other) then one.successor else one.predecessor;
    [Integer, Boolean](Integer) tupleReturningCallable2 = (Integer val) => [val, val.even];
    value spreadingChain2 = chainSpread(tupleReturningCallable2).spread(multipleParametersCallable2);
    assertEquals(spreadingChain2.with(0), 1, "Spreading composition should spread generated tuple to the following callable.");
    assertEquals(spreadingChain2.with(1), 0, "Spreading composition should spread generated tuple to the following callable.");
    //FIXME: Actual type for spreadingChain is ChainingCallable<Boolean?,Integer>, instead of ChainingCallable<Boolean,Integer>
}
