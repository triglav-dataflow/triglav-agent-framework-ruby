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
      DEFAULT_TRIGLAV_ENV = 'development'.freeze

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

      def triglav_env
        @triglav_env ||= ENV['TRIGLAV_ENV'] || DEFAULT_TRIGLAV_ENV
      end

      def config_file
        @cli_options[:config]
      end

      def status_file
        @status_file ||= @cli_options[:status] || (config[:triglav] || {})[:status_file] || 'status.yml'
      end

      def token_file
        @token_file ||= @cli_options[:token] || (config[:triglav] || {})[:token_file] || 'token.yml'
      end

      def dotenv?
        @cli_options[:dotenv]
      end

      def debug?
        @cli_options[:debug]
      end

      def logger
        return @logger if @logger
        opts = serverengine_logger_options
        @logger = Logger.new(opts[:log], opts)
      end

      def serverengine_options
        serverengine_options = config[:serverengine].dup || {}
        # serverengine_options[:workers] = 1 # default
        # serverengine_options[:worker_type] = 'embedded' # default
        serverengine_options.keys.each do |k|
          serverengine_options.delete(k) if k.to_s.start_with?('log')
        end
        serverengine_options[:logger] = logger
        serverengine_options[:setting] = self
        serverengine_options
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
            all[triglav_env.to_sym]
          end
      end

      def serverengine_logger_options
        logger_options = config[:serverengine].dup || {}
        logger_options[:log] ||= DEFAULT_LOG
        logger_options[:log] = @cli_options[:log] if @cli_options[:log]
        logger_options[:log_level] ||= DEFAULT_LOG_LEVEL
        logger_options[:log_level] = @cli_options[:log_level] if @cli_options[:log_level]
        logger_options
      end
    end
  end
end
