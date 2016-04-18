module Goldmine
  class Pivot
    attr_reader :name, :proc

    def initialize(name, array_miner, block)
      @array_miner = array_miner
      @name = name
      @proc = block
      array_miner.pivots << self
    end

    def pivot(name, &block)
      self.class.new(name, array_miner, block)
    end

    def result
      PivotResult.new.tap do |pivot_result|
        array_miner.each do |item|
          keys = array_miner.pivots.each_with_object([]) do |pivot, memo|
            value = pivot.proc.call(item)
            if value.is_a?(Array)
              if value.empty?
                memo << key_for(pivot.name, nil)
              else
                value.each { |v| memo << key_for(pivot.name, v) }
              end
            else
              memo << key_for(pivot.name, value)
            end
          end
          (pivot_result[keys] ||= []) << item
        end
      end
    end

    private

    attr_reader :array_miner

    def key_for(name, value)
      Array.new(2).tap do |key|
        key[0] = name
        key[1] = value
      end
    end
  end
end
