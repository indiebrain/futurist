require "spec_helper"

describe Futurist::Future do

  it "is a proxy for the value of its block" do
    future = Futurist::Future.new { 3 + 2 }

    expect(future.value)
      .to eq(5)
  end
  
  it "forwards arguments to its block" do
    future = Futurist::Future.new(5, 6) { |x, y| x * y }

    expect(future.value)
      .to eq(30)
  end
  
  it "reraises exceptions which occur when the value is retrieved" do
    class FakeError < StandardError; end
    future = Futurist::Future.new { fail FakeError, "whoops!" }

    expect {
      future.value
    }.to raise_exception(FakeError)
  end
end
