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

    expect {
      future.value
    }.to raise_error(FakeError, "fail")
  end

  it "forks a process to evaluate its promise" do
    value = "value"
    forking_method = Process.method(:fork)
    allow(forking_method).
      to receive(:call).
          and_call_original
    future = Futurist::Future.new(forking_method: forking_method) { value }

    future.value

    expect(forking_method).
      to have_received(:call)
  end

  it "cleans up its promise's process" do
    value = "value"
    future = Futurist::Future.new { value }

    future.value
    sleep 0.1
    zombied_children = system("ps -aho pid,state -p #{Process.pid}  | grep -i z")

    expect(zombied_children).
      to eq(false)
  end

  it "is ready after the promise's process has exited" do
    def ready_monitor_factory(process_id)
      stub_monitor(ready: true)
    end
    ready_monitor_factory_method = method(:ready_monitor_factory)
    value = "value"
    future = Futurist::Future.new(promise_monitor_factory_method: ready_monitor_factory_method) { value }
    allow(future).
      to receive(:start_promise_evaluation)

    future.value

    expect(future).
      to be_ready
  end

  it "is not ready when the promise's process has not yet exited" do
    def not_ready_monitor_factory(process_id)
      stub_monitor(ready: false)
    end
    not_ready_monitor_factory_method = method(:not_ready_monitor_factory)
    value = "value"
    future = Futurist::Future.new(promise_monitor_factory_method: not_ready_monitor_factory_method) { value }
    allow(future).
      to receive(:start_promise_evaluation)

    future.value

    expect(future).
      to_not be_ready
  end

  def stub_monitor(ready:)
    double(:monitor_thread).tap do |monitor|
      allow(monitor).
        to receive(:alive?).
            and_return(!ready)
    end
  end
end
