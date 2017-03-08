require "triglav/agent/configuration"
require "triglav/agent/base/setting"
require 'optparse'
require 'serverengine'

module Triglav::Agent
  module Base
    # A base class for cli option parser
    #
    # You usually do not need to customize this class, but if you want to
    # implement your original, configure
    #
    #     Triglav::Agent::Configuration.cli_class =
    class CLI
      def run
        opts, _ = parse_options(ARGV)
        $setting = Configuration.setting_class.new(opts)
        $logger = $setting.logger
        se = ServerEngine.create(nil, Configuration.worker_module) do
          $setting.serverengine_options
        end
        se.run
      end

      def default_opts
        {
          config: 'config.yml',
          dotenv: false,
          debug: false,
        }
      end

      def option_parser(opts = {})
        op = OptionParser.new

        self.class.module_eval do
          define_method(:usage) do |msg = nil|
            puts op.to_s
            puts "error: #{msg}" if msg
            exit 1
          end
        end

        op.on('-c', '--config VALUE', "Config file (default: #{opts[:config]})") {|v|
          opts[:config] = v
        }
        op.on('-s', '--status VALUE', "Status stroage file (default: status.yml)") {|v|
          opts[:status] = v
        }
        op.on('-t', '--token VALUE', "Triglav access token storage file (default: token.yml)") {|v|
          opts[:token] = v
        }
        op.on('--dotenv', "Load environment variables from .env file (default: #{opts[:dotenv]})") {|v|
          opts[:dotenv] = v
        }
        op.on('--debug', "Debug mode (default: #{opts[:debug]})") {|v|
          opts[:debug] = v
        }
        op.on('-h', '--help', "help") {|v|
          opts[:help] = v
        }
        # serverengine options
        op.on('--log VALUE', "Log path (default: #{Setting::DEFAULT_LOG})") {|v|
          opts[:log] = v
        }
        op.on('--log-level VALUE', "Log level (default: #{Setting::DEFAULT_LOG_LEVEL})") {|v|
          opts[:log_level] = v
        }

        op.banner += ''

        op
      end

      def parse_options(argv = ARGV)
        opts = default_opts
        op = option_parser(opts)

        begin
          args = op.parse(argv)
        rescue OptionParser::InvalidOption => e
          usage e.message
        end

        if opts[:help]
          usage
        end

        if opts[:config].nil?
          usage "--config VALUE is required"
        end
        if !File.readable?(opts[:config])
          usage "Config file '#{opts[:config]}' does not exist or not readable"
        end

        [opts, args]
      end
    end
  end
end
