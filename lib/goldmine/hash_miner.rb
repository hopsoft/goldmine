require "delegate"
require "csv"

module Goldmine
  class HashMiner < SimpleDelegator
    attr_reader :source_data

    def initialize(hash={}, source_data: [])
      @source_data = source_data
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
    # @param name [String] The named of the pivot.
    # @yield [Object] Yields once for each item in the Array.
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

    # Returns a new "rolled up" Hash that contains the pivoted count instead of an array of objects.
    #
    # @param percentage [Boolean] Indicates that a percentage of total should be returned instead of the count.
    # @return [Hash] The rollup Hash of data.
    def rollup(percentage: false)
      each_with_object({}) do |pair, memo|
        if percentage
          memo[pair.first] = calculate_percentage(pair.last.size, source_data.size)
        else
          memo[pair.first] = pair.last.size
        end
      end
    end

    # Returns a tabular representation of a pivot rollup. i.e. An Array of Arrays
    # Useful for building CSVs & data visualizations.
    #
    # @param percent_column_name [String] The name of the percent column (percent of total)
    # @param count_column_name [String] The name of the count column (number of objects)
    # @return [Array] The tabular representation of the data.
    def to_tabular(percent_column_name: "percent", count_column_name: "count")
      [].tap do |rows|
        tabular_header_from_key(first.first).tap do |header|
          rows << header.push(percent_column_name, count_column_name) unless header.nil?
        end

        rollup.each do |key, value|
          tabular_row_from_key(key).tap do |row|
            row << calculate_percentage(value, source_data.size)
            row << value
            rows << row
          end
        end
      end
    end

    # Returns an in memory CSV representation of a pivot rollup.
    # Useful for persisting CSVs & building data visualizations.
    #
    # @param percent_column_name [String] The name of the percent column (percent of total)
    # @param count_column_name [String] The name of the count column (number of objects)
    # @return [CSV::Table] The CSV representation of the data.
    def to_csv(percent_column_name: "percent", count_column_name: "count")
      tabular = to_tabular(percent_column_name: percent_column_name, count_column_name: count_column_name)
      header = tabular.shift
      CSV::Table.new tabular.map { |row| CSV::Row.new(header, row) }
    end

    # Assigns a key/value pair to the Hash.
    # @param name [String] The name of a pivot (can be null).
    # @param key [Object] The key to use.
    # @param value [Object] The value to assign
    # @return [Object] The result of the assignment.
    def assign_mined(name, key, value)
      goldmine_key = goldmine_key(name, key)
      self[goldmine_key] ||= []
      self[goldmine_key] << value
    end

    # Creates a key for a pivot-name/key combo.
    # @param name [String] The name of a pivot (can be null).
    # @param key [Object] The key to use.
    # @return [Object] The constructed key.
    def goldmine_key(name, key)
      goldmine_key = { name => key } if name
      goldmine_key ||= key
    end

    private

    def calculate_percentage(count, total)
      return 0.0 unless total > 0
      sprintf("%.2f", count / total.to_f).to_f
    end

    def tabular_header_from_key(key)
      return nil unless key.is_a?(Hash)
      key.keys.map(&:to_s)
    end

    def tabular_row_from_key(key)
      return key.dup if key.is_a?(Array)
      return [key] unless key.is_a?(Hash)
      key.values.dup
    end

  end
end
