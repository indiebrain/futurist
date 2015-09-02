module Futurist
  class ForkingResolutionStrategy
    def initialize(forking_method: Process.method(:fork),
                   process_monitor_constructor: Process.method(:detach),
                   channel: Futurist::Pipe.new,
                   promise:)
      @promise = promise
      @channel = channel
      @forking_method = forking_method
      @value = :not_retrieved
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
                :promise_monitor

    def start_promise_evaluation
      forking_method.call do
        safe_promise = SafePromise.new(promise)
        channel.write(safe_promise.value)
        channel.close_writer
        exit!(0)
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
