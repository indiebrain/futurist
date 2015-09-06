module Futurist
  class ForkingResolutionStrategy
    attr_reader :promise_process_id
    def initialize(forking_method: Process.method(:fork),
                   process_monitor_constructor: Process.method(:detach),
                   channel: Futurist::Pipe.new,
                   process_exit: Process.method(:exit!),
                   promise:)
      @promise = promise
      @channel = channel
      @forking_method = forking_method
      @value = :not_retrieved
      @process_exit = process_exit
      @promise_process_id = start_promise_evaluation
      @promise_monitor = process_monitor_constructor.call(@promise_process_id)
    end

    def resolve
      if @value == :not_retrieved
        @value = read_promise_value
      end
      @value
    end

    def resolved?
      !promise_monitor.alive?
    end

    private

    attr_reader :promise,
                :channel,
                :forking_method,
                :promise_monitor,
                :process_exit

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
