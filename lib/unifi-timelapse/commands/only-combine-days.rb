module UTL

  class OnlyCombineDays < CommandComplex

    class OnlyCombineDaysArguments < UTL::Arguments
    end
    
    def initialize(opts)
      @arguments = OnlyCombineDaysArguments.new(opts)
    end

    def run
      onlyconcat = Command.run(LMerge, all_arguments, {})
      onlyconcat.run
    end

  end
end
