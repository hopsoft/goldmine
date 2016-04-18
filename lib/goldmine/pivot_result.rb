require "forwardable"

module Goldmine
  class PivotResult
    extend Forwardable
    include Enumerable
    def_delegators :@hash, :[], :[]=, :each, :to_h
    attr_reader :rollups

    def initialize(hash={})
      @rollups = []
      @hash = hash
    end

    def rollup(name, &block)
      Rollup.new(name, self, block)
    end
  end
end
