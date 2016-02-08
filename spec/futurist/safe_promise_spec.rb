require "spec_helper"

describe Futurist::SafePromise do
  it "returns the value of the promise" do
    value = double(:value)
    callable = -> () { value }
    promise = Futurist::Promise.new(callable: callable)
    safe_promise = Futurist::SafePromise.new(promise)

    expect(safe_promise.value).
      to eq(value)
  end

  it "returns the exception as its value when the promise raises an error" do
    callable = ->() { fail StandardError, "expected" }
    promise = Futurist::Promise.new(callable: callable)
    safe_promise = Futurist::SafePromise.new(promise)

    expect { safe_promise.value }.
      to_not raise_error
    value = safe_promise.value
    expect(value).
      to be_instance_of(StandardError)
    expect(value.message).
      to eq("expected")
  end
end
