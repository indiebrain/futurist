module Futurist
  class ProcessReadyMonitor

    def initialize(process_id)
      @process_id = process_id
      @ready = false
      spawn_monitoring_thread
    end

    def ready?
      @ready
    end

    private
    attr_reader :process_id

    def spawn_monitoring_thread

      Thread.new do
        Process.wait(process_id)
        @ready = true
      end
    end
  end
end
