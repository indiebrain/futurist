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

  it "is ready when the value calculation is complete" do
    monitor = double(:monitor_instance,
                     complete?: true)
    monitor_class= double(:monitor_class,
                           new: monitor)
    stub_const(
      "Futurist::ProcessCompletionMonitor",
      monitor_class
    )
    work = double(:work)

    future = Futurist::Future.new { work }

    expect(future)
      .to be_ready
  end

  it "is not ready when the value calculation is incomplete" do
    monitor = double(:monitor_instance,
                     complete?: false)
    monitor_class= double(:monitor_class,
                           new: monitor)
    stub_const(
      "Futurist::ProcessCompletionMonitor",
      monitor_class
    )
    work = double(:work)

    future = Futurist::Future.new { work }

    expect(future)
      .to_not be_ready
  end
end
