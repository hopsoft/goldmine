module Goldmine
  class Pivot
    attr_reader :name, :proc

    def initialize(array_miner, name=nil, block)
      @array_miner = array_miner
      @name = name
      @proc = block
      array_miner.pivots << self
    end

    def pivot(name=nil, &block)
      self.class.new(array_miner, name, block)
    end

    def result
      {}.tap do |pivoted|
        array_miner.each do |item|
          keys = array_miner.pivots.each_with_object([]) do |pivot, memo|
            memo << key_for(pivot.name, pivot.proc.call(item))
          end
          (pivoted[keys] ||= []) << item
        end
      end
    end

    private

    attr_accessor :array_miner

    def key_for(name, value)
      return value if name.nil?
      Array.new(2).tap do |key|
        key[0] = name
        key[1] = value
      end
    end
  end
end
