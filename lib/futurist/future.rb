module Futurist
  class Future
    def initialize(execution_strategy: ForkingExecutionStrategy,
                   &block)
      promise = Futurist::Promise.new(callable: block)
      @execution_strategy = execution_strategy.new(promise: promise)
    end

    def value
      @value ||= execution_strategy.value
    end

    def ready?
      execution_strategy.ready?
    end

    private

    attr_reader :execution_strategy
  end
end
