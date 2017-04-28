"Default traits for a chain step"
shared interface Chain<Return> satisfies
          IInvocable<Return>
        & IIterable<Return>
        & ChainingChain<Return>
        & OptionalChain<Return>
        & SpreadingChain<Return>
        & TeeingChain<Return>
        & NullSafeChain<Return>
{}