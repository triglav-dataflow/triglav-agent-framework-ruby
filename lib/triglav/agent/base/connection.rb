module Triglav::Agent
  module Base
    # An abstract base class of Connection.
    #
    # Wrap a connection to a storage.
    # You can implement any methods which you want to use in your Monitor class.
    #
    # You have to implement following methods:
    #
    # * initialize
    # * close
    #
    # An instance is created for each `resource_uri_prefix`, that is,
    # shared among resources with of same `resource_uri_prefix`.
    #
    # Note that multiple connection instances would be created
    # when multiple parallel threads are created in Processor class.
    class Connection
      # @param [Hash] connection_info
      def initialize(connection_info)
        raise NotImplementedError
      end

      # close the connection
      def close
        raise NotImplementedError
      end
    end
  end
end
