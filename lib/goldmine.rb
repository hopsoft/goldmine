$:.unshift File.join(File.dirname(__FILE__), "goldmine")
require "array_miner"
require "hash_miner"

module Goldmine
  class << self
    def miner(object)
      return ArrayMiner.new(object) if object.is_a?(Array)
      return HashMiner.new(object) if object.is_a?(Hash)
      nil
    end

    def sum_rows_on(column, rows)
      rows.reduce(0) { |sum, row| sum += row[column] }
    end

    def sum_pivoted_on(column, pivoted)
      pivoted.each_with_object({}) do |keypair, memo|
        memo[keypair.first] = sum_rows_on(column, keypair.last)
      end
    end
  end
end
