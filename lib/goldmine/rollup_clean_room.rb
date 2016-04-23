module Goldmine
  class RollupCleanRoom
    attr_reader :name, :cache

    def initialize(name, cache={})
      @name = name
      @cache = cache
    end

    def eigen
      class << self
        self
      end
    end

    def rollup(pivoted_list, &block)
      eigen.instance_eval { define_method(:do_rollup, &block) }
      @cache[name] = do_rollup(pivoted_list)
    end
  end
end
