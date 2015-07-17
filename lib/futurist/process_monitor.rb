module Futurist
  class ProcessMonitor

    def initialize(process_id)
      @process_id = process_id
      @exited = false
      spawn_monitoring_thread
    end

    def exited?
      @exited
    end

    private
    attr_reader :process_id

    def spawn_monitoring_thread
      Thread.new do
        Process.wait(process_id)
        @exited = true
      end
    end
  end
end
