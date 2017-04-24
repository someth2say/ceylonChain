"Default traits for a chain step"
shared interface Chain<Return> satisfies
          IInvocable<Return>
        & IIterable<Return>
        & IChainable<Return>
        & IProbable<Return>
        & ISpreadable<Return>
        & IForzable<Return>
        & ITeeable<Return>
        & INullTryable<Return>
{}