require "spec_helper"

describe Futurist::ForkingResolutionStrategy do
  it "forks a process to evaluate its promise" do
    forking_method = Process.method(:fork)
    allow(forking_method).
      to receive(:call).
      and_call_original
    strategy = Futurist::ForkingResolutionStrategy.new(
      forking_method: forking_method,
      promise: stub_promise
    )

    strategy.resolve

    expect(forking_method).
      to have_received(:call)
  end

  it "closes the reader half of the channel" do
    forking_method = ->(&block) { block.call }
    pipe = instance_spy(Futurist::Pipe)
    Futurist::ForkingResolutionStrategy.new(
      forking_method: forking_method,
      promise: stub_promise,
      process_monitor_constructor: -> (_) {},
      process_exit: -> (_) {},
      channel: pipe
    )

    expect(pipe).to have_received(:close_reader)
  end

  it "writes the value to the channel" do
    forking_method = ->(&block) { block.call }
    pipe = instance_spy(Futurist::Pipe)
    Futurist::ForkingResolutionStrategy.new(
      forking_method: forking_method,
      promise: stub_promise,
      process_monitor_constructor: -> (_) {},
      process_exit: -> (_) {},
      channel: pipe
    )

    expect(pipe).to have_received(:write)
  end

  it "closes the writer half of the channel" do
    forking_method = ->(&block) { block.call }
    pipe = instance_spy(Futurist::Pipe)
    Futurist::ForkingResolutionStrategy.new(
      forking_method: forking_method,
      promise: stub_promise,
      process_monitor_constructor: -> (_) {},
      process_exit: -> (_) {},
      channel: pipe
    )

    expect(pipe).to have_received(:close_writer)
  end

  it "it exists with status 0" do
    forking_method = ->(&block) { block.call }
    pipe = instance_double(
      Futurist::Pipe,
      close_reader: nil,
      write: nil,
      close_writer: nil
    )
    process_exit = spy(Process.method(:exit!))
    Futurist::ForkingResolutionStrategy.new(
      forking_method: forking_method,
      promise: stub_promise,
      process_monitor_constructor: -> (_) {},
      process_exit: process_exit,
      channel: pipe
    )

    expect(process_exit).to have_received(:call).
      with(0)
  end

  it "reraises errors which occur in the forked process" do
    error = StandardError.new("expected")
    callable = Proc.new { fail error }
    promise = Futurist::Promise.new(callable: callable)
    strategy = Futurist::ForkingResolutionStrategy.new(promise: promise)

    expect { strategy.resolve }.
      to raise_error(StandardError, "expected")
  end

  it "cleans up its forked process" do
    strategy = Futurist::ForkingResolutionStrategy.new(
      promise: stub_promise
    )

    strategy.resolve
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
    allow_any_instance_of(Futurist::ForkingResolutionStrategy).
      to receive(:start_promise_evaluation)
    strategy = Futurist::ForkingResolutionStrategy.new(
      process_monitor_constructor: ready_monitor_constructor,
      promise: stub_promise
    )
    allow(strategy).
      to receive(:read_promise_value)

    strategy.resolve

    expect(strategy).
      to be_resolved
  end

  it "is not ready when the process has not yet exited" do
    def not_ready_monitor_initializer(_process_id)
      stub_monitor(ready: false)
    end
    not_ready_monitor_constructor = method(:not_ready_monitor_initializer)
    allow_any_instance_of(Futurist::ForkingResolutionStrategy).
      to receive(:start_promise_evaluation)
    strategy = Futurist::ForkingResolutionStrategy.new(
      process_monitor_constructor: not_ready_monitor_constructor,
      promise: stub_promise
    )
    allow(strategy).
      to receive(:read_promise_value)

    strategy.resolve

    expect(strategy).
      to_not be_resolved
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
