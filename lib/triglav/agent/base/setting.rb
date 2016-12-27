require 'triglav/agent/hash_util'
require 'triglav/agent/logger'
require 'yaml'
require 'erb'

module Triglav::Agent
  module Base
    # A base class represents settings coming from config.yml and cli options
    #
    # This base class usually should be enough for agent plugins, but
    # you can override this class and configure with Configuration#setting_class=
    class Setting
      attr_reader :cli_options

      DEFAULT_LOG = 'STDOUT'.freeze
      DEFAULT_LOG_LEVEL = 'info'.freeze
      DEFAULT_APP_ENV = 'development'.freeze

      def initialize(cli_options = {})
        @cli_options = cli_options
        if dotenv?
          require 'dotenv'
          Dotenv.load
        end
      end

      def reload
        Dotenv.overload if dotenv?
        @config = nil
        @logger.close rescue nil
        @logger = nil
      end

      def app_env
        @app_env ||= ENV['APP_ENV'] || DEFAULT_APP_ENV
      end

      def config_file
        @cli_options[:config]
      end

      def status_file
        @status_file ||= @cli_options[:status] || config.dig(:triglav, :status_file) || 'status.yml'
      end

      def token_file
        @token_file ||= @cli_options[:token] || config.dig(:triglav, :token_file) || 'token.yml'
      end

      def dotenv?
        @cli_options[:dotenv]
      end

      def debug?
        @cli_options[:debug]
      end

      def logger
        @logger ||= Logger.new(log, serverengine_logger_options)
      end

      def log_level
        @cli_options[:log_level] || config.dig(:serverengine, :log_level) || DEFAULT_LOG_LEVEL
      end

      def log
        @cli_options[:log] || config.dig(:serverengine, :log) || DEFAULT_LOG
      end

      def serverengine_options
        serverengine_options = config[:serverengine].dup || {}
        # serverengine_options[:workers] = 1 # default
        # serverengine_options[:worker_type] = 'embedded' # default
        serverengine_options.keys.each do |k|
          serverengine_options.delete(k) if k.to_s.start_with?('log')
        end
        serverengine_options.merge!({
          logger: logger,
          log_level: log_level,
          setting: self,
        })
      end

      def [](key)
        config[key]
      end

      def dig(*args)
        config.dig(*args)
      end

      private

      def config
        @config ||=
          begin
            raw = File.read(config_file)
            erb = ERB.new(raw, nil, "-").tap {|_| _.filename = config_file }
            all = HashUtil.deep_symbolize_keys(YAML.load(erb.result(binding)))
            all[app_env.to_sym]
          end
      end

      def serverengine_logger_options
        {
          log: log,
          log_level: log_level,
        }
      end
    end
  end
end
