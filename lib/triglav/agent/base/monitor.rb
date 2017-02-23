module Triglav::Agent
  module Base
    # An abstract class of Monitor.
    #
    # Monitor your storage and send messages to triglav.
    #
    # You have to implement following methods:
    #
    # * initialize
    # * process
    #
    # An instance is created per a `resource`.
    # Connection is shared among same `resource_uri_prefix`.
    #
    # Note that multiple instances would be created,
    # one instance for one parallel thread basically, and
    # `#process` is ran concurrently.
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
