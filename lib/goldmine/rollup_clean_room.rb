require "rollup_cache"

module Goldmine
  class RollupCleanRoom
    attr_reader :name, :cache

    def initialize(name, rollup_cache)
      @name = name
      @cache = rollup_cache
    end

    def eigen
      class << self
        self
      end
    end

    def rollup(pivoted_list, &block)
      eigen.instance_eval { define_method(:do_rollup, &block) }
      @cache.write name, pivoted_list, do_rollup(pivoted_list)
    end

  end
end
