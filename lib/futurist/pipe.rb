module Futurist
  class Pipe

    def initialize(pipe: IO.pipe)
      @reader, @writer = pipe
    end

    def read
      Marshal.load(reader.read)
    end

    def write(value)
      Marshal.dump(value, writer)
    end

    def close_reader
      reader.close
    end

    def close_writer
      writer.close
    end

    private
    attr_reader :reader,
                :writer
  end
end
