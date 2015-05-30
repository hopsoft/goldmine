require "forwardable"
module Goldmine
  class TabularRow
    extend Forwardable
    include Enumerable
    attr_reader :values
    def_delegators :values, :each

    def initialize(header_indexes, values)
      @header_indexes = header_indexes
      @values = values
    end

    # Returns the row value for the header column.
    # Assume numeric indexing into the values when the column passed in an Integer.
    def [](column)
      return values[column] if column.is_a?(Integer)
      values[@header_indexes[column.to_s]] rescue nil
    end
  end
end
