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

  def test_setnx
    Triglav::Agent::StorageFile.set(file, ['a','b'], 'bar')
    assert { Triglav::Agent::StorageFile.setnx(file, ['a','b'], 'bar') == false }
    assert { Triglav::Agent::StorageFile.setnx(file, ['a','new'], 'bar') == true }
  end

  def test_getsetnx
    Triglav::Agent::StorageFile.set(file, ['a','b'], 'bar')
    assert { Triglav::Agent::StorageFile.getsetnx(file, ['a','b'], 'new') == 'bar' }
    assert { Triglav::Agent::StorageFile.getsetnx(file, ['a','new'], 'new') == 'new' }
  end
end
