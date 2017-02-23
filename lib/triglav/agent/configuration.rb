module Triglav
  module Agent
    # Configure Triglav::Agent framework
    #
    #    require 'triglav/agent/configuration'
    #    require 'triglav/agent/vertica/worker'
    #    Triglav::Agent::Configuration.configure do |config|
    #      config.name = :vertica
    #      config.cli_class = Triglav::Agent::Vertica::CLI
    #      config.setting_class = Triglav::Agent::Vertica::Setting
    #      config.worker_module = Triglav::Agent::Vertica::Worker
    #      config.processor_class = Triglav::Agent::Vertica::Processor
    #      config.monitor_class = Triglav::Agent::Vertica::Monitor
    #      config.connection_class = Triglav::Agent::Vertica::Connection
    #    end
    #    Triglav::Agent::Configuration.cli_class.new.run
    class Configuration
      def self.configure(&block)
        yield(Triglav::Agent::Configuration)
      end

      def self.worker_module
        @worker_module ||= Triglav::Agent::Base::Worker
      end

      def self.processor_class
        @processor_class ||= Triglav::Agent::Base::Processor
      end

      def self.monitor_class
        @monitor_class ||= Triglav::Agent::Base::Monitor
      end

      def self.connection_class
        @connection_class ||= Triglav::Agent::Base::Connection
      end

      def self.setting_class
        @setting_class ||= Triglav::Agent::Base::Setting
      end

      def self.cli_class
        @cli_class ||= Triglav::Agent::Base::CLI
      end

      def self.name
        @name ||= 'agent'
      end

      def self.worker_module=(worker_module)
        @worker_module = worker_module
      end

      def self.processor_class=(processor_class)
        @processor_class = processor_class
      end

      def self.monitor_class=(monitor_class)
        @monitor_class = monitor_class
      end

      def self.connection_class=(connection_class)
        @connection_class = connection_class
      end

      def self.setting_class=(setting_class)
        @setting_class = setting_class
      end

      def self.cli_class=(cli_class)
        @cli_class = cli_class
      end

      def self.name=(name)
        @name = name
      end
    end
  end
end
