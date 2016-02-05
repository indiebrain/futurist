module Futurist
  class Future
    def initialize(resolution_strategy_constructor: ForkingResolutionStrategy.public_method(:new),
                   &block)
      promise = Futurist::Promise.new(callable: block)
      @resolution_strategy = resolution_strategy_constructor.call(promise: promise)
    end

    def value
      @value ||= resolution_strategy.resolve
    end

    def ready?
      resolution_strategy.resolved?
    end

    private

    attr_reader :resolution_strategy
  end
end
