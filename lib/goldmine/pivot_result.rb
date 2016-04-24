require "forwardable"
require "rollup"

module Goldmine
  class PivotResult
    extend Forwardable
    include Enumerable
    def_delegators :@hash, :[], :[]=, :each, :to_h
    attr_reader :pivot, :rollups

    def initialize(pivot, hash={})
      @pivot = pivot
      @hash = hash
      @rollups = []
    end

    def rollup(name, &block)
      Rollup.new(name, self, block)
    end
  end
end
