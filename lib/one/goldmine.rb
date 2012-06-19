require "rubygems"

module Goldmine
  module ArrayMiner
    def dig(name=nil, &block)
      reduce({}) do |memo, item|
        value = yield(item)

        if value.is_a?(Array)
          if value.empty?
            memo.assign_mined(name, nil, item)
          else
            value.each { |v| memo.assign_mined(name, v, item) }
          end
        else
          memo.assign_mined(name, value, item)
        end

        memo.goldmine = true
        memo
      end
    end
  end

  module HashMiner
    attr_accessor :goldmine
    def dig(name=nil, &block)
      return self unless goldmined
      reduce({}) do |memo, item|
        key = item.first
        value = item.last
        value.mine(name, &block).each do |k, v|
          new_key = []
          if key.is_a? Array
            new_key = new_key + key
          else
            new_key << key
          end
          new_key << k
          memo[new_key] = v
        end
        memo.goldmine = true
        memo
      end
    end

    def assign_mined(name, key, value)
      mine_key = goldmine_key(name, key)
      self[mine_key] ||= []
      self[goldmine_key(name, key)] << value
    end

    def goldmine_key(name, key)
      mine_key = "#{name}: #{key}" if name
      mine_key ||= key
    end
  end
end

::Array.send(:include, Miner::ArrayMiner)
::Hash.send(:include, Miner::HashMiner)
