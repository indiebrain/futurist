require "spec_helper"

describe Futurist::ProcessMonitor do

  it "is exited when its process has terminated" do
    work = double(:work)
    process_id = fork { work }

    monitor = Futurist::ProcessMonitor.new(process_id)
    sleep_and_wait_until { monitor.exited? }

    expect(monitor)
      .to be_exited
  end

  it "is not exited when its process is still executing" do
    long_running_work = double(:work)
    process_id = fork do
      sleep 5
      long_running_work
    end

    monitor = Futurist::ProcessMonitor.new(process_id)

    expect(monitor)
      .to_not be_exited
  end

  def sleep_and_wait_until(timeout: 5)
    start_time = Time.now
    ::Timeout.timeout(timeout) do
      loop until yield if block_given?
    end
  rescue ::Timeout::Error
    end_time = Time.now
    execution_time = end_time - start_time
    raise "Work timed out after #{execution_time} seconds"
  end
end
