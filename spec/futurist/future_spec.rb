require "spec_helper"

describe Futurist::Future do

  it "returns the value of its block at some future point in time" do
    value = "value"

    future = Futurist::Future.new { value }

    expect(future.value).
      to eq(value)
  end

  it "reraises exceptions which occur in its block's execution" do
    class FakeError < StandardError; end
    future = Futurist::Future.new { fail(FakeError, "fail") }

    expect {
      future.value
    }.to raise_error(FakeError, "fail")
  end

  it "computes the value of its block" do
    value = "value"
    worker = Futurist::Future.new { value }

    expect(worker.value).
      to eq(value)
  end

  it "forks a worker process to compute the value of its block" do
    value = "value"
    forking_method = Process.method(:fork)
    allow(forking_method).
      to receive(:call).
          and_call_original
    worker = Futurist::Future.new(forking_method: forking_method) { value }

    worker.value

    expect(forking_method).
      to have_received(:call)
  end

  it "cleans up its worker process" do
    value = "value"
    worker = Futurist::Future.new { value }

    worker.value
    sleep 0.1
    zombied_children = system("ps -aho pid,state -p #{Process.pid}  | grep -i z")

    expect(zombied_children).
      to eq(false)
  end

  it "is ready after the forked worker process has exited" do
    def ready_monitor_method(process_id)
      stub_monitor(ready: true)
    end
    ready_monitor_method = method(:ready_monitor_method)
    value = "value"
    worker = Futurist::Future.new(process_monitoring_method: ready_monitor_method) { value }
    allow(worker).
      to receive(:start_worker)

    worker.value

    expect(worker).
      to be_ready
  end

  it "is not ready when the forked worker process has not yet exited" do
    def not_ready_monitor_method(process_id)
      stub_monitor(ready: false)
    end
    ready_monitor_method = method(:not_ready_monitor_method)
    value = "value"
    worker = Futurist::Future.new(process_monitoring_method: ready_monitor_method) { value }
    allow(worker).
      to receive(:start_worker)

    worker.value

    expect(worker).
      to_not be_ready
  end

  def stub_monitor(ready:)
    double(:monitor_thread).tap do |monitor|
      allow(monitor).
        to receive(:alive?).
            and_return(!ready)
    end
  end
end
