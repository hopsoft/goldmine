module Goldmine
  class Rollup
    attr_reader :name

    def initialize(name, pivot_result)
      @name = name
      @pivot_result = pivot_result
    end

    def rollup(name)
    end

  end
end

