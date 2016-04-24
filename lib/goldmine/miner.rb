require "forwardable"
require "pivot"

module Goldmine
  class Miner
    extend Forwardable
    include Enumerable
    def_delegators :@array, :each, :to_a
    attr_reader :pivots, :cache

    def initialize(array=[], cache: false)
      @pivots = []
      @array = array.to_a
      @cache = cache
    end

    def pivot(name, &block)
      Pivot.new(name, self, block)
    end
  end
end
