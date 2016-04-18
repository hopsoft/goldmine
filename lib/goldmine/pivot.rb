module Goldmine
  class Pivot
    attr_reader :name, :proc

    def initialize(name=nil, array_miner, block)
      @array_miner = array_miner
      @name = name
      @proc = block
      array_miner.pivots << self
    end

    def pivot(name=nil, &block)
      self.class.new(name, array_miner, block)
    end

    def result
      PivotResult.new.tap do |pivot_result|
        array_miner.each do |item|
          keys = array_miner.pivots.each_with_object([]) do |pivot, memo|
            memo << key_for(pivot.name, pivot.proc.call(item))
          end
          (pivot_result[keys] ||= []) << item
        end
      end
    end

    private

    attr_reader :array_miner

    def key_for(name, value)
      return value if name.nil?
      Array.new(2).tap do |key|
        key[0] = name
        key[1] = value
      end
    end
  end
end
