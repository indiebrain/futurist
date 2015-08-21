require "spec_helper"

describe Futurist::Promise do
  it "is a proxy to the value of its callable" do
    value = double(:value)
    callable = Proc.new { value }
    promise = Futurist::Promise.new(callable: callable)

    expect(promise.value).
      to eq(value)
  end

  it "has a value of an error instance when the callable raises an error" do
    error = StandardError.new("expected")
    callable = Proc.new { fail error }
    promise = Futurist::Promise.new(callable: callable)

    expect { promise.value }.
      to_not raise_error

    expect(promise.value).
      to eq(error)
  end
end
