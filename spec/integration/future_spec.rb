require "spec_helper"

describe Futurist::Future do
  it "receives the value of its promise at some future point in time" do
    future = Futurist::Future.new(resolution_strategy_constructor: strategy) { "value" }

    expect(future.value).
      to eq("value")
  end

  it "reraises exceptions which occur in its promise's execution" do
    class FakeError < StandardError; end
    future = Futurist::Future.new(resolution_strategy_constructor: strategy) { fail(FakeError, "fail") }

    expect { future.value }.
      to raise_error(FakeError, "fail")
  end

  private

  def strategy
    Futurist::Bounder.new(concurrencey: 1, strategy: Futurist::ForkingResolutionStrategy.method(:new))
  end
end
