require "forwardable"
require "tabular_row"

module Goldmine
  class TabularData
    extend Forwardable
    include Enumerable
    attr_reader :header, :header_indexes, :rows, :tabular_rows
    def_delegators :tabular_rows, :each, :[]

    def initialize(header, rows)
      set_header header
      set_rows rows
    end

    def sort_by(&block)
      TabularData.new header, tabular_rows.sort_by(&block).map(&:values)
    end

    def to_a
      rows.dup.tap { |a| a.insert 0, header }
    end

    private

    def set_header(header)
      @header = header
      @header_indexes = header.each_with_index.with_object({}) do |name_with_index, memo|
        memo[name_with_index.first] = name_with_index.last
      end
    end

    def set_rows(rows)
      @rows = rows
      @tabular_rows = rows.map do |row|
        TabularRow.new(header_indexes, row)
      end
    end

  end
end
