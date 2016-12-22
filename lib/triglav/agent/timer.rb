module Triglav::Agent
  # A timer utility to run serverengine worker in a time interval
  #
  #     module Triglav::Agent
  #       module Worker
  #         def initialize
  #           @timer = Timer.new
  #         end
  #
  #         def run
  #           interval = 60.0 # sec
  #           until @stop
  #             @timer.wait(interval) { process }
  #           end
  #         end
  #
  #         def stop
  #           @stop = true
  #           @timer.signal
  #         end
  #       end
  #     end
  class Timer
    def initialize
      @r, @w = IO.pipe
    end

    def wait(sec, &block)
      started = Time.now
      yield
      elapsed = Time.now - started
      if (timeout = (sec - elapsed).to_f) > 0
        IO.select([@r], [], [], timeout)
        @r.read_nonblock(0, nil, exception: false)
      end
    end

    def signal
      @w.puts ' '
    end

    # # Hmm, Ctrl-C breaks condvar.wait before calling #stop unexpectedly
    # attr_reader :condvar, :mutex
    #
    # def initialize
    #   @condvar = ConditionVariable.new
    #   @mutex = Mutex.new
    # end
    #
    # def wait(sec, &block)
    #   started = Time.now
    #   @mutex.synchronize do
    #     yield
    #     elapsed = (Time.now - started).to_f
    #     @condvar.wait(@mutex, sec - elapsed)
    #   end
    # end
    #
    # def signal
    #   @condvar.signal
    # end
  end
end
