require "delegate"
require "csv"

module Goldmine
  class HashRollup < SimpleDelegator
    attr_reader :names

    def initialize(pivoted, cache=Cache.new)
      @names = []
      @cache = cache
      @context = RollupContext.new(@cache)
      @pivoted = pivoted
      super @rolled = {}
    end

    def rollup(name, &block)
      names << name
      pivoted.each do |key, value|
        @cache.fetch(name, value) do
          rolled[key] ||= {}
          rolled[key][name] = @context.instance_exec(value, &block)
        end
      end
      self
    end

    def to_tabular
      [].tap do |rows|
        rows << tabular_header
        rows.concat tabular_rows
      end
    end

    def to_csv_table
      header = tabular_header
      rows = tabular_rows.map { |row| CSV::Row.new(header, row) }
      CSV::Table.new rows
    end

    private

    attr_reader :pivoted, :rolled

    def tabular_header
      return [] if empty?
      to_tabular_header keys.first, values.first
    end

    def tabular_rows
      map do |pair|
        to_tabular_row pair.first, pair.last
      end
    end

    def to_tabular_row(key, value)
      row = key.values.dup if key.is_a?(Hash)
      row ||= as_array(key).dup
      row.concat value.values
    end

    def to_tabular_header(key, value)
      header = key.keys.map(&:to_s) if key.is_a?(Hash)
      header ||= (1..as_array(key).size).map { |i| "column#{i}" }
      header.concat value.keys.map(&:to_s)
    end

    def as_array(value)
      return value if value.is_a?(Array)
      [value]
    end


  end
end
