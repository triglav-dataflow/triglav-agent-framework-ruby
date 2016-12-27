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
    # @return [Hash]
    def self.load(path)
      open(path) {|fp| fp.load }
    end

    # Open storage file
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
