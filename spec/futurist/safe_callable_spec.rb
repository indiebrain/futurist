require "spec_helper"

describe Futurist::SafeCallable do

  it "returns the value of the callable" do
    value = double(:value)
    safe_callable = Futurist::SafeCallable.new(Proc.new { value })

    expect(safe_callable.call).
      to eq(value)
  end

  it "returns the exception as its value when the callable throws an error" do
    safe_callable = Futurist::SafeCallable.new(Proc.new { fail StandardError, "expected" })

    expect {
      safe_callable.call
    }.to_not raise_error
    expected_error = safe_callable.call
    expect(expected_error).
      to be_instance_of(StandardError)
    expect(expected_error.message).
      to eq("expected")
  end
end
