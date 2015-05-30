require "delegate"
require "tabular_data"

module Goldmine
  class HashMiner < SimpleDelegator
    attr_reader :source_data

    def initialize(hash={}, source_data: nil)
      @source_data = source_data || hash
      super hash
    end

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

      reduce(HashMiner.new(source_data: source_data)) do |memo, item|
        key = item.first
        value = Goldmine.miner(item.last)
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

    # Returns the pivot keys.
    # @return [Array]
    def pivoted_keys
      key = first.first # key from first entry
      return key.keys if key.is_a?(Hash)
      [key]
    end

    # Returns pivoted data as tabular data with header & rows.
    # Tabular data can be used to build CSVs or user interfaces more easily.
    # @return [Array] Tabular data
    def to_tabular
      rows = map do |pair|
        [].tap do |row|
          row.concat extract_values_from_pivot_key(pair.first)
          row << sprintf("%.2f", (pair.last.size / source_data.size.to_f)).to_f
          row << pair.last.size
        end
      end
      header = [pivoted_keys.map(&:to_s), "Percent of Total", "Count"].flatten
      TabularData.new(header, rows)
    end

    def to_a
      to_tabular.to_a
    end

    private

    def extract_values_from_pivot_key(pivot_key)
      return pivot_key.values if pivot_key.is_a?(Hash)
      [pivot_key]
    end

  end
end
