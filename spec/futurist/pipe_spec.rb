require "spec_helper"

describe Futurist::Pipe do

  it "can be written to and read from" do
    pipe = Futurist::Pipe.new
    value = "value"

    pipe.write(value)
    pipe.close_writer

    expect(pipe.read).
      to eq(value)
  end

  it "writes to its writer IO" do
    writer = stub_writer
    io_pair = stub_io_pair(writer: writer)
    pipe = Futurist::Pipe.new(pipe: io_pair)
    value = "value"

    pipe.write(value)

    expect(writer).
      to have_received(:write)
  end

  it "reader from its reader IO" do
    reader = stub_reader
    allow(reader).
      to receive(:read).
          and_return(Marshal.dump("value"))
    io_pair = stub_io_pair(reader: reader)
    pipe = Futurist::Pipe.new(pipe: io_pair)

    pipe.read

    expect(reader).
      to have_received(:read)
  end

  it "closes its writer IO" do
    writer = stub_writer
    io_pair = stub_io_pair(writer: writer)
    pipe = Futurist::Pipe.new(pipe: io_pair)

    pipe.close_writer

    expect(writer).
      to have_received(:close)
  end

  it "closes its reader IO" do
    reader = stub_reader
    io_pair = stub_io_pair(reader: reader)
    pipe = Futurist::Pipe.new(pipe: io_pair)

    pipe.close_reader

    expect(reader).
      to have_received(:close)
  end

  def stub_io_pair(reader: stub_reader,
                writer: stub_writer)
    [reader, writer]
  end

  def stub_reader
    double(:reader).tap do |reader|
      allow(reader).
        to receive(:read)
      allow(reader).
        to receive(:close)
    end
  end

  def stub_writer
    double(:writer).tap do |writer|
      allow(writer).
        to receive(:write)
      allow(writer).
        to receive(:close)
    end
  end
end
