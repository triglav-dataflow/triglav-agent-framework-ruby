require_relative 'storage_file'
require 'set'

module Triglav::Agent
  class Status
    attr_accessor :path
    attr_reader :resource_uri_prefix, :resource_uri

    VERSION = :v1

    def initialize(resource_uri_prefix = nil, resource_uri = nil)
      @path = $setting.status_file
      @resource_uri_prefix = resource_uri_prefix.to_sym if resource_uri_prefix
      @resource_uri = resource_uri.to_sym if resource_uri
      @parents = [VERSION, @resource_uri_prefix, @resource_uri].compact
    end

    # set(val)
    # set(key, val)
    # set(key1, key2, val)
    # set([key], val)
    # set([key1, key2], val)
    def set(*args)
      val = args.pop
      keys = args.flatten
      StorageFile.set(path, [*@parents, *keys], val)
    end

    # Merge Hash value with existing Hash value.
    #
    # merge!(val)
    # merge!(key, val)
    # merge!(key1, key2, val)
    # merge!([key], val)
    # merge!([key1, key2], val)
    def merge!(*args)
      val = args.pop
      keys = args.flatten
      StorageFile.merge!(path, [*@parents, *keys], val)
    end

    # setnx(val)
    # setnx(key, val)
    # setnx(key1, key2, val)
    # setnx([key], val)
    # setnx([key1, key2], val)
    def setnx(*args)
      val = args.pop
      keys = args.flatten
      StorageFile.setnx(path, [*@parents, *keys], val)
    end

    # getsetnx(val)
    # getsetnx(key, val)
    # getsetnx(key1, key2, val)
    # getsetnx([key], val)
    # getsetnx([key1, key2], val)
    def getsetnx(*args)
      val = args.pop
      keys = args.flatten
      StorageFile.getsetnx(path, [*@parents, *keys], val)
    end

    # get(key)
    # get(key1, key2)
    # get([key])
    # get([key1, key2])
    def get(*args)
      keys = (args || []).flatten
      StorageFile.get(path, [*@parents, *keys])
    end

    def self.select_resource_uri_prefixes!(resource_uri_prefixes)
      Triglav::Agent::StorageFile.select!($setting.status_file, [VERSION], resource_uri_prefixes.map(&:to_sym))
    end

    def self.select_resource_uris!(resource_uri_prefix, resource_uris)
      Triglav::Agent::StorageFile.select!($setting.status_file, [VERSION, resource_uri_prefix.to_sym], resource_uris.map(&:to_sym))
    end
  end
end
