module Futurist
  class Future

    def initialize(*arguments,
                   &block)
      @arguments = arguments
      @block = block
      @value = :no_value
      @pipe = IO.pipe
      @worker_pid = fork_worker_process
    end
    
    def value
      if @value == :no_value
        @value = read_worker_results
      end
      @value
    end
 
    private
    attr_accessor :worker_pid
    attr_reader :arguments,
                :block,
                :pipe,
                :worker_pid

    def fork_worker_process
      read, write = pipe

      fork do
        read.close
        begin
          result = block.call(arguments)
        rescue => e
          result = e
        end
        Marshal.dump(result, write)
        exit!(0)
      end
    end

    def read_worker_results
      read, write = pipe

      write.close
      Process.wait(worker_pid)
      raw_result = read.read
      result = Marshal.load(raw_result)
      if result.kind_of?(Exception)
        raise result
      end
      result
    end
  end
end
