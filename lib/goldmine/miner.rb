require "forwardable"

module Goldmine
  class Miner
    extend Forwardable
    include Enumerable
    def_delegators :@array, :each
    attr_reader :pivots

    def initialize(array=[])
      @pivots = []
      @array = array.to_a
    end

    def pivot(name=nil, &block)
      Pivot.new(self, name, block)
    end
  end
end
