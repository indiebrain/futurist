require "forwardable"

module Futurist
  class Bounder
    extend Forwardable

    def initialize(concurrencey:, strategy:)
      @concurrencey = concurrencey
      @run_list = []
      @run_list_lock = Mutex.new
      @strategy = strategy
    end

    def call(promise:)
      resolvable = strategy.call(promise: promise, eagerly_resolve: false)
      add_to_run_list(resolvable)

      resolvable
    end

    private

    attr_reader :concurrencey, :run_list, :run_list_lock, :strategy

    def_delegator :run_list_lock, :synchronize

    def add_to_run_list(resolvable)
      resolvable.run
      run_list << resolvable
    end
  end
end
