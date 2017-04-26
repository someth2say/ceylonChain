"Default traits for a chain step"
shared interface Chain<Return> satisfies
          IInvocable<Return>
        & IIterable<Return>
        & ChainingChain<Return>
        & ProbingChain<Return>
        & ISpreadable<Return>
        & ForcingChain<Return>
        & TeeingChain<Return>
        & NullSafeChain<Return>
{}