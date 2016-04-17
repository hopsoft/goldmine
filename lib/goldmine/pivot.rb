module Goldmine
  class Pivot
    attr_reader :array_miner, :name, :proc
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
      data = {}
      array_miner.each do |item|
        keys = []

        array_miner.pivots.each_with_index do |pivot, index|
          value = pivot.proc.call(item)

          if pivot.name.nil?
            key = value
          else
            key = Array.new(2)
            key[0] = pivot.name
            key[1] = value
          end

          keys << key
        end

        data[keys] ||= []
        data[keys] << item
      end
      data
    end
  end
end
