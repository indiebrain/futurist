require "spec_helper"

describe Futurist::Promise do
  it "is a proxy to the value of its callable" do
    value = double(:value)
    callable = Proc.new { value }
    promise = Futurist::Promise.new(callable: callable)

    expect(promise.value).
      to eq(value)
  end
end
