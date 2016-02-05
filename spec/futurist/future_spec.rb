require "spec_helper"

describe Futurist::Future do

  it "is ready after the promise's value has finished calculating" do
    resolution_strategy = double("ResolutionStrategy",
                                 resolved?: true)
    resolution_strategy_constructor = ->(_) { resolution_strategy }

    future = Futurist::Future.new(
      resolution_strategy_constructor: resolution_strategy_constructor
    ) { "value" }

    expect(future).
      to be_ready
  end

  it "is not ready before the promise's value has finished calculating" do
    resolution_strategy = double("ResolutionStrategy",
                                 resolved?: false)
    future = Futurist::Future.new(
      resolution_strategy_constructor: ->(_) { resolution_strategy }
    ) { value }
    allow(future).
      to receive(:start_promise_evaluation)

    expect(future).
      to_not be_ready
  end

  it "is valued by the resolution of its promise" do
    resolution_strategy = double("ResolutionStrategy",
                                 resolve: "value")

    future = Futurist::Future.new(
      resolution_strategy_constructor: ->(_) { resolution_strategy }
    )

    expect(future.value).
      to eq("value")
  end
end
