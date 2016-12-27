module Triglav::Agent
  class HashUtil
    def self.deep_symbolize_keys(obj)
      case obj
      when Hash
        obj.map {|k, v| [k.to_sym, deep_symbolize_keys(v)] }.to_h
      when Array
        obj.map {|v| deep_symbolize_keys(v) }
      else
        obj
      end
    end

    def self.deep_stringify_keys(obj)
      case obj
      when Hash
        obj.map {|k, v| [k.to_s, deep_stringify_keys(v)] }.to_h
      when Array
        obj.map {|v| deep_stringify_keys(v) }
      else
        obj
      end
    end

    #   HashUtil.setdig(hash, ['a', 'b'], 'bar') # like hash['a']['b'] = 'bar'
    def self.setdig(hash, key, val)
      keys = Array(key)
      sub_hash = hash
      keys[0...-1].each do |k|
        sub_hash = (sub_hash[k] ||= {})
      end
      sub_hash[keys.last] = val
      hash
    end
  end
end
