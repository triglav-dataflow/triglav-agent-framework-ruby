# frozen_string_literal: true

require_relative 'helper'
require 'fileutils'
require 'securerandom'

if ENV['TEST_API_CLIENT']
  class TestApiClient < Test::Unit::TestCase
    def teardown
      FileUtils.rm_f(file)
    end

    def file
      $setting.status_file
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
      client = Triglav::Agent::ApiClient.new
      res = client.send_messages([message])
      assert { res.num_inserts == 1 }
    end

    def test_list_aggregated_resources
      client = Triglav::Agent::ApiClient.new
      assert_nothing_raised do
        res = client.list_aggregated_resources('hdfs://')
      end
    end
  end
end
