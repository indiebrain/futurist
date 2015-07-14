module Futurist
  class Future

    def initialize(*arguments,
                   &block)
      @arguments = arguments
      @block = block
      @value = :no_value
      @pipe = IO.pipe
      @worker_pid = fork_worker_process
      @worker_process_completion_monitor = ProcessCompletionMonitor.new(worker_pid)
    end

    def value
      if @value == :no_value
        @value = read_worker_results
      end
      @value
    end

    def ready?
      @worker_process_completion_monitor.complete?
    end

    private
    attr_accessor :worker_pid
    attr_reader :arguments,
                :block,
                :pipe,
                :worker_pid,
                :worker_process_completion_monitor

    def fork_worker_process
      reader, writer = pipe

      fork do
        reader.close
        begin
          result = block.call(arguments)
        rescue => e
          result = e
        end
        Marshal.dump(result, writer)
        exit!(0)
      end
    end

    def read_worker_results
      reader, writer = pipe

      writer.close
      raw_result = reader.read
      result = Marshal.load(raw_result)
      if result.kind_of?(Exception)
        raise result
      end
      result
    end
  end
end
