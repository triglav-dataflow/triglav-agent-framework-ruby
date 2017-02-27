require 'triglav/agent/storage_file'
require 'triglav_client'

module Triglav::Agent
  # This Triglav client connects to triglav API with $setting.triglav.url,
  # and authenticates with $setting.triglav.credential, and
  # stores the token into $setting.token_file.
  #
  # Re-authenticate automatically if token is expired
  #
  #     require 'triglav/agent/api_client'
  #
  #     api_client = Triglav::Agent::ApiClient.new
  #     resources = api_client.list_resources(uri_prefix)
  #     resources.each do |resource|
  #       events = get_events(resource) # implement this!
  #       api_client.send_messages(events)
  #     end
  class ApiClient
    class Error < StandardError
      attr_reader :cause
      def initialize(message, cause)
        @cause = cause
        super(message)
      end
    end
    class AuthenticationError < Error; end
    class ConnectionError < Error; end

    # Initialize TriglavClient
    def initialize(opts = {})
      @opts = opts || {}
      config = TriglavClient::Configuration.new do |config|
        uri = URI.parse(triglav_url)
        config.scheme = uri.scheme
        config.host = "#{uri.host}:#{uri.port}"
        config.timeout = timeout if timeout
        config.debugging = debugging if debugging
      end
      @api_client = TriglavClient::ApiClient.new(config)
      initialize_current_token
      authenticate
    end

    def close
      # typhoeus makes a new connection and disconnects it on each request
    end

    # List resources required to be monitored
    #
    # @param [String] uri_prefix
    # @return [Array of TriglavClient::ResourceEachResponse] array of resources
    # @see TriglavClient::ResourceEachResponse
    def list_aggregated_resources(uri_prefix)
      $logger.debug { "ApiClient#list_aggregated_resources(#{uri_prefix.inspect})" }
      resources_api = TriglavClient::ResourcesApi.new(@api_client)
      handle_error { resources_api.list_aggregated_resources(uri_prefix) }
    end

    # Send messages
    #
    # @param [Array of TriglavClient::MessageRequest] array of event messages
    # @see TriglavClient::MessageRequest
    def send_messages(events)
      $logger.debug { "ApiClient#send_messages(#{events.inspect})" }
      messages_api = TriglavClient::MessagesApi.new(@api_client)
      handle_error { messages_api.send_messages(events) }
    end

    def authorized?
      @current_token.has_key?(:access_token)
    end

    private

    # Authenticate
    #
    # 1. Another process saved a newer token onto the token_file => read it
    # 2. The token saved on the token_file is same with current token => re-authenticate
    # 3. The token saved on the token_file is older than the current token
    #   => unknown situation, re-authenticate and save into token_file to refresh anyway
    # 4. No token is saved on the token_file => authenticate
    def authenticate
      $logger.debug { 'ApiClient#authenticate' }
      StorageFile.open(token_file) do |fp|
        token = fp.load
        if should_read_token_from_file?(token)
          $logger.debug { "Read token from file" }
          update_current_token(token)
          return
        end
        $logger.debug { "AuthApi#create_token" }
        auth_api = TriglavClient::AuthApi.new(@api_client)
        credential = TriglavClient::Credential.new(
          username: username, password: password, authenticator: authenticator
        )
        handle_auth_error do
          $logger.debug { 'TriglavClient::AuthApi' }
          result = auth_api.create_token(credential)
          token = {access_token: result.access_token}
          update_current_token(token)
          fp.dump(token)
        end
      end
    end

    def initialize_current_token
      @current_token = {
        access_token: (@api_client.config.api_key['Authorization'] = String.new),
      }
    end

    def update_current_token(token)
      @current_token[:access_token].replace(token[:access_token])
    end

    def should_read_token_from_file?(token)
      return true if @current_token[:access_token].empty? && !(token[:access_token] ||= '').empty?
      return @current_token[:access_token] != token[:access_token]
    end

    def handle_auth_error(&block)
      retries = 0
      begin
        yield
      rescue TriglavClient::ApiError => e
        if e.code == 0
          if retries < max_retries
            sleep retry_interval
            retries += 1
            retry
          end
          raise ConnectionError.new("Could not connect to #{triglav_url} with #{retries} retries", e)
        elsif e.message == 'Unauthorized'.freeze
          raise AuthenticationError.new("Failed to authenticate on triglav API.".freeze, e)
        else
          raise Error.new(e.message, e)
        end
      end
    end

    def handle_error(&block)
      retries = 0
      begin
        yield
      rescue TriglavClient::ApiError => e
        if e.code == 0
          if retries < max_retries
            sleep retry_interval
            retries += 1
            retry
          end
          raise ConnectionError.new("Could not connect to #{triglav_url} with #{retries} retries", e)
        elsif e.message == 'Unauthorized'.freeze
          authenticate
          retry
        else
          raise Error.new(e.message, e)
        end
      end
    end

    def triglav_url
      @opts[:url] || $setting.dig(:triglav, :url)
    end

    def username
      @opts.dig(:credential, :username) || $setting.dig(:triglav, :credential, :username)
    end

    def password
      @opts.dig(:credential, :password) || $setting.dig(:triglav, :credential, :password)
    end

    def authenticator
      @opts.dig(:credential, :authenticator) || $setting.dig(:triglav, :credential, :authenticator)
    end

    def timeout
      @opts[:timeout] || $setting.dig(:triglav, :timeout)
    end

    def debugging
      @opts[:debugging] || $setting.dig(:triglav, :debugging)
    end

    def max_retries
      @opts[:retries] || $setting.dig(:triglav, :retries) || 3
    end

    def retry_interval
      @opts[:retry_interval] || $setting.dig(:triglav, :retry_interval) || 3 # second
    end

    def token_file
      @opts[:token_file] || $setting.token_file
    end
  end
end
