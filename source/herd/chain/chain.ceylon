"Default traits for a chain step"
shared interface Chain<Return> satisfies
          IInvocable<Return>
        & IIterable<Return>
        & ChainingChain<Return>
        & ProbingChain<Return>
        & StrippingChain<Return>
        & SpreadingChain<Return>
        & TeeingChain<Return>
        & NullSafeChain<Return>
{}