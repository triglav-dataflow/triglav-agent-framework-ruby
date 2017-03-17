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

  def test_merge!
    Triglav::Agent::StorageFile.set(file, 'foo', {foo: 'foo'})
    Triglav::Agent::StorageFile.merge!(file, 'foo', {bar: 'bar'})
    assert { Triglav::Agent::StorageFile.get(file, 'foo') == {foo: 'foo', bar: 'bar'} }

    Triglav::Agent::StorageFile.merge!(file, 'not_exists', {foo: 'bar'})
    assert { Triglav::Agent::StorageFile.get(file, 'not_exists') == {foo: 'bar'} }
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

  def test_select!
    Triglav::Agent::StorageFile.set(file, ['a','a'], 'val')
    Triglav::Agent::StorageFile.set(file, ['a','b'], 'val')
    Triglav::Agent::StorageFile.set(file, ['a','c'], 'val')
    Triglav::Agent::StorageFile.select!(file, ['a'], ['b', 'c'])
    params = Triglav::Agent::StorageFile.load(file)
    assert { params = {'a' => {'b' => 'val', 'c' => 'val'} } }
  end
end
