require "rubygems"

module Goldmine
  module ArrayMiner
    def pivot(name=nil, &block)
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
    def pivot(name=nil, &block)
      return self unless goldmine
      reduce({}) do |memo, item|
        key = item.first
        value = item.last
        value.pivot(name, &block).each do |k, v|
          if key.is_a? Hash
            k = { block.to_s => k } unless k.is_a?(Hash)
            new_key = key.merge(k)
          else
            new_key = [key, k]
          end
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
      mine_key = { name => key } if name
      mine_key ||= key
    end
  end
end

::Array.send(:include, Goldmine::ArrayMiner)
::Hash.send(:include, Goldmine::HashMiner)
