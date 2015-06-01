require "delegate"

module Goldmine
  class ArrayMiner < SimpleDelegator
    attr_reader :source_data

    def initialize(array=[], source_data: [])
      @source_data = source_data
      super array
    end

    # Pivots the Array into a Hash of mined data.
    # Think of it as creating a pivot table or perhaps an OLAP cube.
    #
    # @example Simple pivot
    #   list = [1,2,3,4,5,6,7,8,9]
    #   data = list.pivot { |i| i < 5 }
    #
    #   # resulting data
    #   # {
    #   #   true  => [1, 2, 3, 4],
    #   #   false => [5, 6, 7, 8, 9]
    #   # }
    #
    # @example Named pivot
    #   list = [1,2,3,4,5,6,7,8,9]
    #   data = list.pivot("less than 5") { |i| i < 5 }
    #
    #   # resulting data
    #   # {
    #   #   { "less than 5" => true } => [1, 2, 3, 4],
    #   #   { "less than 5" => false } => [5, 6, 7, 8, 9]
    #   # }
    #
    # @example Chained pivot
    #   list = [1,2,3,4,5,6,7,8,9]
    #   data = list.pivot { |i| i < 5 }.pivot { |i| i % 2 == 0 }
    #
    #   # resulting data
    #   {
    #     [true, false]  => [1, 3],
    #     [true, true]   => [2, 4],
    #     [false, false] => [5, 7, 9],
    #     [false, true]  => [6, 8]
    #   }
    #
    # @param [String] name The named of the pivot.
    # @yield [Object] Yields once for each item in the Array
    # @return [Hash] The pivoted Hash of data.
    def pivot(name=nil, &block)
      reduce(HashMiner.new(source_data: self)) do |memo, item|
        value = yield(item)

        if value.is_a?(Array)
          if value.empty?
            memo.assign_mined(name, nil, item)
          else
            value.each { |v| memo.assign_mined(name, v, item) }
          end
        else
          memo.assign_mined(name, value, item)
        end

        memo.goldmine = true
        memo
      end
    end

  end
end
