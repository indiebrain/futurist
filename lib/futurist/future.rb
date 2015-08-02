module Futurist
  class Future

    def initialize(forking_method: Process.method(:fork),
                   promise_monitor_factory_method: Process.method(:detach),
                   channel: Futurist::Pipe.new,
                   &promise_callable)
      @promise_callable = promise_callable
      @channel = channel
      @forking_method = forking_method
      @value = :not_retrieved
      @promise_process_id = start_promise_evaluation
      @promise_monitor = promise_monitor_factory_method.call(@promise_process_id)
    end

    def value
      if @value == :not_retrieved
        @value = read_promise_value
      end
      @value
    end

    def ready?
      !promise_monitor.alive?
    end

    private
    attr_reader :promise_callable,
                :channel,
                :forking_method,
                :promise_monitor

    def start_promise_evaluation
      forking_method.call do
        value = SafeCallable.new(promise_callable).call
        channel.write(value)
        channel.close_writer
        exit!(0)
      end
    end

    def read_promise_value
      channel.close_writer
      value = channel.read
      channel.close_reader
      if value.kind_of?(Exception)
        raise value
      end
      value
    end
  end
end
