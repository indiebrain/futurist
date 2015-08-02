module Futurist
  class SafeCallable
    def initialize(callable)
      @callable = callable
    end

    def call
      begin
        callable.call
      rescue => error
        error
      end
    end

    private
    attr_reader :callable
  end
end
