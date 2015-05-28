require "delegate"

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
      first.first.keys
    end

    # Returns pivoted data as a tabular Array that can be used to build CSVs or user interfaces.
    # @return [Array] Tabular pivot data
    # @yield [Array] sort_by block for sorting the Array
    def to_a(&block)
      rows = map do |pair|
        [].tap do |row|
          row.concat pair.first.values
          row << pair.last.size
        end
      end
      rows = rows.sort_by(&block) if block_given?
      header = pivoted_keys.map(&:to_s) << "total"
      rows.insert 0, header
      rows
    end

  end
end
