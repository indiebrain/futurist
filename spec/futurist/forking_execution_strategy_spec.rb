require "spec_helper"

describe Futurist::ForkingExecutionStrategy do
  it "forks a process to evaluate its promise" do
    forking_method = Process.method(:fork)
    allow(forking_method).
      to receive(:call).
      and_call_original
    strategy = Futurist::ForkingExecutionStrategy.new(
      forking_method: forking_method,
      promise: stub_promise
    )

    strategy.value

    expect(forking_method).
      to have_received(:call)
  end

  it "reraises errors which occur in the forked process" do
    error = StandardError.new("expected")
    callable = Proc.new { fail error }
    promise = Futurist::Promise.new(callable: callable)
    strategy = Futurist::ForkingExecutionStrategy.new(promise: promise)

    expect { strategy.value }.
      to raise_error(StandardError, "expected")
  end

  it "cleans up its forked process" do
    strategy = Futurist::ForkingExecutionStrategy.new(
      promise: stub_promise
    )

    strategy.value
    sleep 0.1
    zombied_children = system("ps -aho pid,state -p #{Process.pid} | grep -i z")

    expect(zombied_children).
      to eq(false)
  end

  it "is ready after the process has exited" do
    def ready_monitor_initializer(_process_id)
      stub_monitor(ready: true)
    end
    ready_monitor_constructor = method(:ready_monitor_initializer)
    allow_any_instance_of(Futurist::ForkingExecutionStrategy).
      to receive(:start_promise_evaluation)
    strategy = Futurist::ForkingExecutionStrategy.new(
      process_monitor_constructor: ready_monitor_constructor,
      promise: stub_promise
    )
    allow(strategy).
      to receive(:read_promise_value)

    strategy.value

    expect(strategy).
      to be_ready
  end

  it "is not ready when the process has not yet exited" do
    def not_ready_monitor_initializer(_process_id)
      stub_monitor(ready: false)
    end
    not_ready_monitor_constructor = method(:not_ready_monitor_initializer)
    allow_any_instance_of(Futurist::ForkingExecutionStrategy).
      to receive(:start_promise_evaluation)
    strategy = Futurist::ForkingExecutionStrategy.new(
      process_monitor_constructor: not_ready_monitor_constructor,
      promise: stub_promise
    )
    allow(strategy).
      to receive(:read_promise_value)

    strategy.value

    expect(strategy).
      to_not be_ready
  end

  def stub_monitor(ready:)
    double(:monitor_thread).tap do |monitor|
      allow(monitor).
        to receive(:alive?).
        and_return(!ready)
    end
  end

  def stub_promise
    double(:promise).tap do |promise|
      allow(promise).
        to receive(:value).
        and_return("value")
    end
  end
end
