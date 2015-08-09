module Futurist
  class Future

    def initialize(forking_method: Process.method(:fork),
                   promise_monitor_factory_method: Process.method(:detach),
                   channel: Futurist::Pipe.new,
                   &block)
      @promise = Futurist::Promise.new(callable: block)
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
    attr_reader :promise,
                :channel,
                :forking_method,
                :promise_monitor

    def start_promise_evaluation
      forking_method.call do
        channel.write(promise.value)
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
