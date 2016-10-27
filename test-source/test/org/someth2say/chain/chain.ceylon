import ceylon.test {
    test,
    assertEquals
}
import org.someth2say.chain {
    ...
}

Integer(String) stringSizeCallable = String.size;
ChainingCallable<Integer,String> stringSizeChain = chain(stringSizeCallable);
String helloMessage = "Hello Ceylon";
String byeMessage = "ByeBye Ceylon";
Integer?(Integer) evenOrNullCallable => (Integer num) => if (num.even) then num else null;

shared test void invocation() {
    // Chain start and parameter setting
    assertEquals(stringSizeChain.with(helloMessage), stringSizeCallable(helloMessage), "Invoking a ChainStart should directly invoke the method on the params"); //12
}

shared test void composition() {
    value integerEvenCallable = Integer.even;
    value printStringSizeEven = stringSizeChain.andThen(integerEvenCallable);

    assertEquals(printStringSizeEven.with(helloMessage), integerEvenCallable(stringSizeCallable(helloMessage)), "Chained callables should be equivalent to invonking those callables in the opposing order."); // true
    assertEquals(printStringSizeEven.with(byeMessage), integerEvenCallable(stringSizeCallable(byeMessage)), "Chained callables should be equivalent to invonking those callables in the opposing order."); // false
}

shared test void conditionalComposition(){
    value successorCallable = Integer.successor;
    value successorIfEvenChain = chain(evenOrNullCallable).ifExistsThen(successorCallable);
    assertEquals(successorIfEvenChain.with(0), 1 , "Not null values in conditional composition should behave like normal composition.");
    assertEquals(successorIfEvenChain.with(1), null, "Null should be spread to the right with conditional composition.");
}

shared test void spreadingComposition() {
    value multipleParametersCallable = (Object one, Object other) => one.equals(other);
    function tupleReturningCallable(Integer val) => if (val.even) then [val, val] else [val, val.successor];

    value spreadingChain = chain(tupleReturningCallable).ifSpreadThen(multipleParametersCallable);
    assertEquals(spreadingChain.with(0),true,"Spreading composition should spread generated tuple to the following callable.");
    assertEquals(spreadingChain.with(1),false,"Spreading composition should spread generated tuple to the following callable.");
    //FIXME: Actual type for spreadingChain is ChainingCallable<Boolean?,Integer>, instead of ChainingCallable<Boolean,Integer>
}
