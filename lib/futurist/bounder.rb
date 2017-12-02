require "forwardable"

module Futurist
  class Bounder
    extend Forwardable

    def initialize(concurrencey:, strategy:)
      @backlog = Queue.new
      @concurrencey = concurrencey
      @running = []
      @running_lock = Mutex.new
      @strategy = strategy

      run
    end

    def call(promise:)
      resolvable = strategy.call(promise: promise, eagerly_resolve: false)
      add_to_run_list(resolvable)

      resolvable
    end

    private

    attr_reader :backlog, :concurrencey, :running, :running_lock, :strategy

    def_delegator :running_lock, :synchronize

    def add_to_run_list(resolvable)
      backlog.push(resolvable)
    end

    def run
      Thread.new do
        loop do
          clear_resolved
          schedule_new_work
        end
      end
    end

    def clear_resolved
      synchronize do
        running.delete_if(&:resolved?)
      end
    end

    def schedule_new_work
     synchronize do
       (concurrencey - running.size).times do
         resolvable = backlog.pop
         resolvable.run
         running << resolvable
       end
     end
    end
  end
end
