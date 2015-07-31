module Futurist
  class Future

    def initialize(forking_method: Process.method(:fork),
                   process_monitoring_method: Process.method(:detach),
                   channel: IO.pipe,
                   &block)
      @forking_method = forking_method
      @block = block
      @reader, @writer = channel
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
                :forking_method,
                :process_monitor,
                :reader,
                :writer

    def start_worker
      forking_method.call do
        reader.close
        begin
          value = block.call
        rescue => e
          value = e
        end
        Marshal.dump(value, writer)
        writer.close
        exit!(0)
      end
    end

    def read_worker_value
      writer.close
      value = Marshal.load(reader.read)
      if value.kind_of?(Exception)
        raise value
      end
      value
    end
  end
end
