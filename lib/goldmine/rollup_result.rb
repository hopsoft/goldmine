require "forwardable"

module Goldmine
  class RollupResult
    extend Forwardable
    include Enumerable
    def_delegators :@pivot_result, :[], :[]=, :each, :to_h

    def initialize(pivot_result={})
      @pivot_result = pivot_result
    end

    def to_rows
    end

    private

    attr_reader :pivot_result

  end
end
