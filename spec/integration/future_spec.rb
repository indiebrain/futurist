require "spec_helper"

describe Futurist::Future do
  it "receives the value of its promise at some future point in time" do
    future = Futurist::Future.new { "value" }

    expect(future.value).
      to eq("value")
  end

  it "reraises exceptions which occur in its promise's execution" do
    class FakeError < StandardError; end
    future = Futurist::Future.new { fail(FakeError, "fail") }

    expect { future.value }.
      to raise_error(FakeError, "fail")
  end
end
