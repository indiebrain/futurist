module Futurist
  class Future
    def initialize(promise_execution_strategy: ForkingPromiseExecutionStrategy,
                   &block)
      promise = Futurist::Promise.new(callable: block)
      @promise_execution_strategy = promise_execution_strategy.new(
        promise: promise
      )
    end

    def value
      @value ||= promise_execution_strategy.value
    end

    def ready?
      promise_execution_strategy.ready?
    end

    private

    attr_reader :promise_execution_strategy
  end
end
