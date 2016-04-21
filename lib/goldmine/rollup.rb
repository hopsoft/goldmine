require "rollup_cache"
require "rollup_clean_room"
require "rollup_result"

module Goldmine
  class Rollup
    attr_reader :name, :proc

    def initialize(name, pivot_result, block)
      @name = name
      @pivot_result = pivot_result
      @proc = block
      pivot_result.rollups << self
    end

    def rollup(name, &block)
      self.class.new(name, pivot_result, block)
    end

    def result(cache: false)
      cache = RollupCache.new if cache
      RollupResult.new.tap do |rollup_result|
        pivot_result.each do |pivot_key, pivoted_list|
          pivot_result.rollups.each do |rollup|
            Array.new(2).tap do |computed_value|
              key = rollup.name
              value = RollupCleanRoom.new(key, cache).rollup(pivoted_list, &rollup.proc) if cache
              value ||= rollup.proc.call(pivoted_list)
              computed_value[0] = key
              computed_value[1] = value
              (rollup_result[pivot_key] ||= []) << computed_value
            end
          end
        end
      end
    end

    private

    attr_reader :pivot_result

  end
end

