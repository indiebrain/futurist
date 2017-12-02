require 'forwardable'

module Futurist
  class ForkingResolutionStrategy
    extend Forwardable

    attr_reader :promise_process_id
    def initialize(forking_method: Process.method(:fork),
                   process_monitor_constructor: Process.method(:detach),
                   channel_constructor: Futurist::Pipe.method(:new),
                   process_exit: Process.method(:exit!),
                   promise:,
                   eagerly_resolve: true
                  )
      @promise = promise
      @channel_constructor = channel_constructor
      @forking_method = forking_method
      @value = :not_retrieved
      @process_exit = process_exit
      @process_monitor_constructor = process_monitor_constructor
      @run_called = false
      @run_lock = Mutex.new
      if eagerly_resolve
        run
      end
    end

    def run
      synchronize do
        construct_channel
        @promise_process_id = start_promise_evaluation
        @promise_monitor = process_monitor_constructor.call(@promise_process_id)
        @run_called = true
      end
    end

    def resolve
      block_until_run
      if @value == :not_retrieved
        @value = read_promise_value
      end
      @value
    end

    def block_until_run
        until(run_called?); end
    end

    def resolved?
      !promise_monitor.alive?
    end

    private

    def_delegator :@run_lock, :synchronize

    attr_reader :promise,
                :channel_constructor,
                :forking_method,
                :promise_monitor,
                :process_exit,
                :process_monitor_constructor,
                :channel

    def construct_channel
      @channel ||= channel_constructor.call
    end

    def run_called?
      synchronize do
        @run_called
      end
    end

    def start_promise_evaluation
      forking_method.call do
        channel.close_reader
        safe_promise = SafePromise.new(promise)
        channel.write(safe_promise.value)
        channel.close_writer
        process_exit.call(0)
      end
    end

    def read_promise_value
      channel.close_writer
      value = channel.read
      channel.close_reader
      if value.is_a?(Exception)
        raise value
      end
      value
    end
  end
end
