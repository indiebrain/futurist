require "spec_helper"

describe Futurist::Future do
  it "receives the value of its promise at some future point in time" do
    value = "value"
    future = Futurist::Future.new { value }

    expect(future.value).
      to eq(value)
  end

  it "reraises exceptions which occur in its promise's execution" do
    class FakeError < StandardError; end
    future = Futurist::Future.new { fail(FakeError, "fail") }

    expect { future.value }.
      to raise_error(FakeError, "fail")
  end

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
