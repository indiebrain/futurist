module Futurist
  class ProcessCompletionMonitor

    def initialize(process_id)
      @process_id = process_id
      @complete = false
      spawn_monitoring_thread
    end

    def complete?
      @complete
    end

    private
    attr_reader :process_id

    def spawn_monitoring_thread
      Thread.new do
        Process.wait(process_id)
        @complete = true
      end
    end
  end
end
