require 'triglav/agent/timer'

module Triglav::Agent
  module Base
    # Just a skelton of ServerEngine worker
    module Worker
      def initialize
        @timer = Timer.new
      end

      def reload
        $setting.reload
      end

      def run
        interval = 60
        until @stop
          @timer.wait(interval) { process }
        end
      end

      def stop
        @stop = true
        @timer.signal
      end

      def process
        raise NotImplementedError
      end
    end
  end
end
