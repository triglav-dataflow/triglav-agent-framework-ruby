module Triglav::Agent
  module Base
    # Just a skelton
    # An instance is created per a resource
    class Monitor
      # @param [Triglav::Agent::Base::Connection] connection
      # @param [TriglavClient::ResourceResponse] resource
      def initialize(connection, resource)
        raise NotImplementedError
      end

      # @yield [events] Gives an array of events
      def process(&block)
        raise NotImplementedError
        # yield(events) if block_given?
      end
    end
  end
end
