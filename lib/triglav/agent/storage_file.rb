require 'triglav/agent/hash_util'
require 'yaml'

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
      fp = File.open(path, (File::RDONLY | File::CREAT))
      until fp.flock(File::LOCK_EX | File::LOCK_NB)
        $logger.info { "Somebody else is locking the storage file #{path.inspect}" }
        sleep 0.5
      end
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
        sub_params = params = fp.load
        keys[0...-1].each do |k|
          sub_params = (sub_params[k] ||= {})
        end
        sub_params[keys.last] = val
        fp.dump(params)
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
      open(path) {|fp| fp.load.dig(*keys) }
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
  end
end
