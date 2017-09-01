require 'triglav/agent/hash_util'
require 'yaml'
require 'set'

module Triglav::Agent
  # Thread and inter-process safe YAML file storage
  #
  #     StorageFile.open($setting.status_file) do |fp|
  #       status = fp.load
  #       status['foo'] = 'bar'
  #       fp.dump(status)
  #     end
  class StorageFile
    attr_reader :fp

    private def initialize(fp)
      @fp = fp
    end

    # Load storage file
    #
    # @return [Hash]
    def load
      if !(content = @fp.read).empty?
        YAML.load(content) # all keys must be symbols
      else
        {}
      end
    end

    # Dump to storage file
    #
    # @param [Hash] hash
    def dump(hash)
      File.write(@fp.path, YAML.dump(hash))
    end

    # Load storage file
    #
    #     StorageFile.load($setting.status_file)
    #
    # @param [String] path
    # @return [Hash]
    def self.load(path)
      open(path) {|fp| fp.load }
    end

    # Open storage file
    #
    #     StorageFile.open($setting.status_file) do |fp|
    #       status = fp.load
    #       status['foo'] = 'bar'
    #       fp.dump(status)
    #     end
    #
    # @param [String] path
    # @param [Block] block
    def self.open(path, &block)
      # Use RDONLY instead of WRONLY not to TRUNCate contents
      fp = File.open(path, (File::RDONLY | File::CREAT))
      fp.flock(File::LOCK_EX)
      begin
        return yield(StorageFile.new(fp))
      ensure
        fp.flock(File::LOCK_UN)
        fp.close rescue nil
      end
    end

    # Open storage file to read
    #
    #     StorageFile.readopen($setting.status_file) do |fp|
    #       status = fp.load
    #     end
    #
    # @param [String] path
    # @param [Block] block
    def self.readopen(path, &block)
      fp = File.open(path, (File::RDONLY | File::CREAT))
      fp.flock(File::LOCK_SH)
      begin
        return yield(StorageFile.new(fp))
      ensure
        fp.flock(File::LOCK_UN)
        fp.close rescue nil
      end
    end

    # Set storage file with given key, value
    #
    #     StorageFile.set($setting.status_file, 'foo', 'bar') # like h['foo'] = 'bar'
    #     StorageFile.set($setting.status_file, ['a','b'], 'bar') # like h['a']['b'] = 'bar'
    #
    # @param [String] path
    # @param [Object] key
    # @param [Object] val
    def self.set(path, key, val)
      keys = Array(key)
      open(path) do |fp|
        params = fp.load
        HashUtil.setdig(params, keys, val)
        fp.dump(params)
      end
    end

    # Merge Hash value with existing Hash value.
    #
    # @param [String] path
    # @param [Object] key
    # @param [Hash] val
    # @return [Object] holded value
    def self.merge!(path, key, val)
      keys = Array(key)
      open(path) do |fp|
        params = fp.load
        _val = params.dig(*keys) || {}
        _val.merge!(val) 
        HashUtil.setdig(params, keys, _val)
        fp.dump(params)
        return _val
      end
    end

    # Set key to hold val if key does not exist
    #
    #     StorageFile.setnx($setting.status_file, 'foo', 'bar') # like h['foo'] = 'bar'
    #     StorageFile.setnx($setting.status_file, ['a','b'], 'bar') # like h['a']['b'] = 'bar'
    #
    # @param [String] path
    # @param [Object] key
    # @param [Object] val
    # @return [Boolean] true if set (not exist), false if not set (exists)
    def self.setnx(path, key, val)
      keys = Array(key)
      open(path) do |fp|
        params = fp.load
        return false if params.dig(*keys)
        HashUtil.setdig(params, keys, val)
        fp.dump(params)
        return true
      end
    end

    # Set key to hold val if key does not exist and returns the holded value
    #
    # This is a kind of atomic short hand of
    #
    #     StorageFile.setnx($setting.status_file, 'foo', 'bar')
    #     StorageFile.get($setting.status_file, 'foo')
    #
    # @param [String] path
    # @param [Object] key
    # @param [Object] val
    # @return [Object] holded value
    def self.getsetnx(path, key, val)
      keys = Array(key)
      open(path) do |fp|
        params = fp.load
        if curr = params.dig(*keys)
          return curr
        end
        HashUtil.setdig(params, keys, val)
        fp.dump(params)
        return val
      end
    end

    # Get value of the given key from storage file
    #
    #     StorageFile.get($setting.status_file, 'foo') # like h['foo'] = 'bar'
    #     StorageFile.get($setting.status_file, ['a','b']) # like hash['a']['b']
    #
    # @param [String] path
    # @param [Object] key
    def self.get(path, key)
      keys = Array(key)
      readopen(path) {|fp| fp.load.dig(*keys) }
    end

    # Keep specified keys, and remove others
    #
    # @param [String] path
    # @param [Array] parent keys of hash
    # @param [Array] keys
    def self.select!(path, parents = [], keys)
      open(path) do |fp|
        params = fp.load
        if dig = (parents.empty? ? params : params.dig(*parents))
          removes = dig.keys - keys
          unless removes.empty?
            $logger.info { "Remove from status: #{{parent_keys: parents, keys: removes}}" }
            removes.each {|k| dig.delete(k) }
          end
        end
        fp.dump(params)
      end
    end
  end
end
