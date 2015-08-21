module Futurist
  class SafePromise
    def initialize(promise)
      @promise = promise
    end

    def value
      promise.value
    rescue => error
      error
    end

    private

    attr_reader :promise
  end
end
