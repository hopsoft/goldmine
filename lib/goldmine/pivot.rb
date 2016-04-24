require "forwardable"
require "pivot_result"
require "rollup"

module Goldmine
  class Pivot
    extend Forwardable
    def_delegators :result, :to_h
    attr_reader :miner, :name, :proc

    def initialize(name, miner, block)
      @miner = miner
      @name = name
      @proc = block
      miner.pivots << self
    end

    def pivot(name, &block)
      self.class.new(name, miner, block)
    end

    def rollup(name, &block)
      Rollup.new(name, result, block)
    end

    def result
      PivotResult.new(self).tap do |pivot_result|
        miner.each do |item|
          key_data = miner.pivots.each_with_object(key: [], keys: []) do |pivot, memo|
            value = pivot.proc.call(item)
            if value.is_a?(Array)
              if value.empty?
                memo[:key] << key_for(pivot.name, nil)
              else
                value.each { |v| memo[:keys] << key_for(pivot.name, v) }
              end
            else
              memo[:key] << key_for(pivot.name, value)
            end
          end
          (pivot_result[key_data[:key]] ||= []) << item unless key_data[:key].empty?
          key_data[:keys].each do |key|
            (pivot_result[key] ||= []) << item
          end
        end
      end
    end

    private

    def key_for(name, value)
      Array.new(2).tap do |key|
        key[0] = name
        key[1] = value
      end
    end
  end
end
