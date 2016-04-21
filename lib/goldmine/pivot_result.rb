require "forwardable"
require "rollup"

module Goldmine
  class PivotResult
    extend Forwardable
    include Enumerable
    def_delegators :@hash, :[], :[]=, :each, :to_h
    attr_reader :rollups, :cache

    def initialize(hash={})
      @rollups = []
      @hash = hash
      @cache = {}
    end

    def rollup(name, &block)
      Rollup.new(name, self, block)
    end
  end
end
