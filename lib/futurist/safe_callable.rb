module Futurist
  class SafeCallable
    def initialize(callable)
      @callable = callable
    end

    def call
      callable.call
    rescue => error
      error
    end

    private

    attr_reader :callable
  end
end
