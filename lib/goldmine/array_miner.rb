module Goldmine
  class ArrayMiner
    include Enumerable
    attr_reader :pivots

    def initialize(array=[])
      @pivots = []
      @array = array.to_a
    end

    def each
      @array.each do |item|
        yield item
      end
    end

    def pivot(name=nil, &block)
      Pivot.new(self, name, block)
    end
  end
end
