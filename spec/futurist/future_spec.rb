require "spec_helper"

describe Futurist::Future do

  it "is ready after the promise's value has finished calculating" do
    class ResolvedResolutionStrategy < FakeResolutionStrategy
      def resolved?
        true
      end
    end

    value = "value"
    future = Futurist::Future.new(
      resolution_strategy: ResolvedResolutionStrategy
    ) { value }

    future.value

    expect(future).
      to be_ready
  end

  it "is not ready before the promise's value has finished calculating" do
    class NotResolvedResolutionStrategy < FakeResolutionStrategy
      def resolved?
        false
      end
    end

    value = "value"
    future = Futurist::Future.new(
      resolution_strategy: NotResolvedResolutionStrategy
    ) { value }
    allow(future).
      to receive(:start_promise_evaluation)

    future.value

    expect(future).
      to_not be_ready
  end

  class FakeResolutionStrategy
    def initialize(promise:)
      @promise = promise
    end

    def resolve
      @promise.value
    end
  end
end
