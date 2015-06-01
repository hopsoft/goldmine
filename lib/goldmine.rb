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
  end
end
