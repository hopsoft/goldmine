require "rubygems"

# Goldmine brings pivot table behavior to Arrays.
module Goldmine

  # Extends Array with a pivot method.
  module ArrayMiner

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
      reduce({}) do |memo, item|
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

  # Extends Hash with a pivot method.
  module HashMiner

    attr_accessor :goldmine

    # Further pivots the Hash into mined data.
    # This method is what enables the pivot method chaining.
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
    # @note This method should not be called directly. Call Array#pivot instead.
    #
    # @param [String] name The named of the pivot.
    # @yield [Object] Yields once for each item in the Array
    # @return [Hash] The pivoted Hash of data.
    def pivot(name=nil, &block)
      return self unless goldmine

      reduce({}) do |memo, item|
        key = item.first
        value = item.last
        value.pivot(name, &block).each do |k, v|
          if key.is_a? Hash
            k = { block.to_s => k } unless k.is_a?(Hash)
            new_key = key.merge(k)
          else
            new_key = [key, k].flatten
          end
          memo[new_key] = v
        end
        memo.goldmine = true
        memo
      end
    end

    # Assigns a key/value pair to the Hash.
    # @param [String] name The name of a pivot (can be null).
    # @param [Object] key The key to use.
    # @param [Object] value The value to assign
    # @return [Object] The result of the assignment.
    def assign_mined(name, key, value)
      goldmine_key = goldmine_key(name, key)
      self[goldmine_key] ||= []
      self[goldmine_key] << value
    end

    # Creates a key for a pivot-name/key combo.
    # @param [String] name The name of a pivot (can be null).
    # @param [Object] key The key to use.
    # @return [Object] The constructed key.
    def goldmine_key(name, key)
      goldmine_key = { name => key } if name
      goldmine_key ||= key
    end

  end
end

::Array.send(:include, Goldmine::ArrayMiner)
::Hash.send(:include, Goldmine::HashMiner)
