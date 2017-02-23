module Triglav::Agent
  module Base
    # Just a skelton
    # An instance is created per a connection_info, and shared among monitor instances
    class Connection
      # @param [Hash] connection_info
      def initialize(connection_info)
        raise NotImplementedError
      end
    end
  end
end
