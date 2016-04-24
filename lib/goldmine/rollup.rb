require "forwardable"
require "rollup_clean_room"
require "rollup_result"

module Goldmine
  class Rollup
    extend Forwardable
    def_delegators :result, :to_h, :to_rows, :to_hash_rows, :to_tabular, :to_csv_table, :to_csv
    def_delegators :pivot_result, :pivot
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
      perform_caching = cache || pivot.miner.cache
      RollupResult.new.tap do |rollup_result|
        pivot_result.each do |pivot_key, pivoted_list|
          stash = {} if perform_caching
          pivot_result.rollups.each do |rollup|
            Array.new(2).tap do |computed_value|
              key = rollup.name
              value = RollupCleanRoom.new(key, stash).rollup(pivoted_list, &rollup.proc) if perform_caching
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
