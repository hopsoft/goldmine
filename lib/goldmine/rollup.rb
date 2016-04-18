module Goldmine
  class Rollup
    attr_reader :name, :proc

    def initialize(name, pivot_result, block)
      @name = name
      @pivot_result = pivot_result
      @proc = block
      pivot_result.rollups << self
    end

    def rollup(name, &block)
      self.class.new(name, pivot_result, block)
    end

    def result
      {}.tap do |rolled|
        pivot_result.each do |pivot_key, pivot_entries|
          pivot_result.rollups.each do |rollup|
            Array.new(2).tap do |computed_value|
              computed_value[0] = rollup.name
              computed_value[1] = rollup.proc.call(pivot_entries)
              (rolled[pivot_key] ||= []) << computed_value
            end
          end
        end
      end
    end

    private

    attr_reader :pivot_result
  end
end

