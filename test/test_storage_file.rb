# frozen_string_literal: true

require_relative 'helper'
require 'fileutils'

class TestStorageFile < Test::Unit::TestCase
  def teardown
    FileUtils.rm_f(file)
  end

  def file
    $setting.status_file
  end

  def test_set_get
    Triglav::Agent::StorageFile.set(file, 'foo', 'bar')
    assert { Triglav::Agent::StorageFile.get(file, 'foo') == 'bar' }

    Triglav::Agent::StorageFile.set(file, ['a','b'], 'bar')
    assert { Triglav::Agent::StorageFile.get(file, ['a','b']) == 'bar' }
  end
end
