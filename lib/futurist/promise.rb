module Futurist
  class Promise

    def initialize(callable:)
      @callable = SafeCallable.new(callable)
    end

    def value
      callable.call
    end

    private
    attr_reader :callable
  end
end
