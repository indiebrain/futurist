module Futurist
  class Future

    def initialize(forking_method: Process.method(:fork),
                   process_monitoring_method: Process.method(:detach),
                   channel: Futurist::Pipe.new,
                   &block)
      @block = block
      @channel = channel
      @forking_method = forking_method
      @value = :not_retrieved
      @worker_process_id = start_worker
      @process_monitor = process_monitoring_method.call(@worker_process_id)
    end

    def value
      if @value == :not_retrieved
        @value = read_worker_value
      end
      @value
    end

    def ready?
      !process_monitor.alive?
    end

    private
    attr_reader :block,
                :channel,
                :forking_method,
                :process_monitor

    def start_worker
      forking_method.call do
        value = SafeCallable.new(block).call
        channel.write(value)
        channel.close_writer
        exit!(0)
      end
    end

    def read_worker_value
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
