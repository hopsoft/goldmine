module Goldmine
  class Pivot
    attr_reader :array, :name, :proc
    def initialize(array, name=nil, block)
      @array = array
      @name = name
      @proc = block
    end

    def pivot(name=nil, &block)
      array.pivot(name, &block)
    end

    def result
      data = {}
      array.each do |item|
        keys = []

        array.pivots.each_with_index do |pivot, index|
          value = pivot.proc.call(item)
          key = value if name.nil?
          key ||= begin
            k = {}
            k[name] = value
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
