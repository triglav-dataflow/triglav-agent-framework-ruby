# frozen_string_literal: true

require_relative 'helper'
require 'fileutils'
require 'securerandom'

if ENV['TEST_API_CLIENT']
  class TestApiClient < Test::Unit::TestCase
    def setup
      FileUtils.rm_f($setting.token_file)
    end

    def teardown
      FileUtils.rm_f($setting.token_file)
    end

    def client
      Triglav::Agent::ApiClient.new
    end

    def test_authenticate
      client = Triglav::Agent::ApiClient.new
      assert { client.authorized? == true }
    end

    def test_send_messages
      message = TriglavClient::MessageRequest.new({
        uuid: SecureRandom.uuid,
        resource_uri: 'hdfs://path/to',
        resource_unit: 'daily',
        resource_time: Time.now.to_i,
        resource_timezone: '+09:00',
        payload: {}.to_json,
      })
      res = client.send_messages([message])
      assert { res.num_inserts == 1 }
    end

    def test_list_aggregated_resources
      assert_nothing_raised do
        res = client.list_aggregated_resources('hdfs://')
      end
    end

    def test_retry_handle_auth_error
      any_instance_of(TriglavClient::AuthApi) do |klass|
        stub(klass).create_token { raise TriglavClient::ApiError.new(code: 0) }
      end
      begin
        client = Triglav::Agent::ApiClient.new(retries: 3, retry_interval: 0, timeout: 0)
        assert(false)
      rescue Triglav::Agent::ApiClient::ConnectionError => e
        assert { e.message =~ /3 retries/ }
      end
    end

    def test_retry_handle_error
      client = Triglav::Agent::ApiClient.new(retries: 3, retry_interval: 0, timeout: 0)
      begin
        any_instance_of(TriglavClient::ResourcesApi) do |klass|
          stub(klass).list_aggregated_resources { raise TriglavClient::ApiError.new(code: 0) }
        end
        client.list_aggregated_resources('hdfs://')
        assert(false)
      rescue Triglav::Agent::ApiClient::ConnectionError => e
        assert { e.message =~ /3 retries/ }
      end
    end
  end
end
