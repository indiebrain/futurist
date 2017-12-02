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
      channel_constructor: ->() { pipe }
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
      channel_constructor: ->() { pipe }
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
      channel_constructor: ->(){ pipe }
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
      channel_constructor: ->() { pipe }
    )

    expect(process_exit).to have_received(:call).
      with(0)
  end

  it "reraises errors which occur in the forked process" do
    error = StandardError.new("expected")
    callable = ->() { fail error }
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

    expect(process_exited_and_cleaned_up?(strategy.promise_process_id)).
      to eq(true)
  end

  it "is ready after the process has exited" do
    allow_any_instance_of(Futurist::ForkingResolutionStrategy).
      to receive(:start_promise_evaluation)
    strategy = Futurist::ForkingResolutionStrategy.new(
      process_monitor_constructor: ->(_) { stub_monitor(ready: true) },
      promise: stub_promise
    )
    allow(strategy).
      to receive(:read_promise_value)

    strategy.resolve

    expect(strategy).
      to be_resolved
  end

  it "is not ready when the process has not yet exited" do
    allow_any_instance_of(Futurist::ForkingResolutionStrategy).
      to receive(:start_promise_evaluation)
    strategy = Futurist::ForkingResolutionStrategy.new(
      process_monitor_constructor: ->(_) { stub_monitor(ready: false) },
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

  def wait_for_pid_to_exit(pid, timeout = 0.1)
    start_time = Time.now
    while Time.now - start_time <= timeout
      begin
        Process.kill(0, pid)
      rescue Errno::ESRCH
        break
      end
    end
  end

  def process_is_not_running?(pid)
    wait_for_pid_to_exit(pid)
    Process.kill(0, pid)
    false
  rescue Errno::ESRCH
    true
  end

  def process_has_been_cleaned_up?(pid)
    Process.waitpid(pid, Process::WNOHANG)
    false
  rescue Errno::ECHILD
    true
  end

  def process_exited_and_cleaned_up?(pid)
    if process_is_not_running?(pid) &&
       process_has_been_cleaned_up?(pid)
      true
    else
      false
    end
  end
end
