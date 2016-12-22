module Triglav::Agent
  # A timer utility to run serverengine worker in a time interval
  #
  #     module Triglav::Agent
  #       module Worker
  #         def initialize
  #           @interval = 60.0 # sec
  #         end
  #
  #         def run
  #           @timer = Timer.new
  #           @stop = false
  #           until @stop
  #             @timer.wait(@interval) { process }
  #           end
  #         end
  #
  #         def stop
  #           @stop = true
  #           @timer.stop
  #         end
  #       end
  #     end
  class Timer
    def initialize
      @r, @w = IO.pipe
    end

    def wait(sec, &block)
      return if @stop
      started = Time.now
      yield
      elapsed = Time.now - started
      if (timeout = (sec - elapsed).to_f) > 0
        begin
          IO.select([@r], [], [], timeout)
        rescue IOError, Errno::EBADF
          # these error may occur if @r is closed during IO.select. Ignore it
        end
      end
    end

    def stop
      @stop = true
      signal
      close
    end

    private

    def signal
      @w.puts ' '
    end

    def close
      @w.close rescue nil
      @w = nil
      @r.close rescue nil
      @r = nil
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
