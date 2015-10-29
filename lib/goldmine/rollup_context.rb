module Goldmine
  class RollupContext
    def initialize(cache)
      @cache = cache
      @computations = {}
    end

    def computed(name)
      @computations[name.to_sym] ||= Computation.new(name, @cache)
    end

    class Computation
      def initialize(name, cache)
        @name = name
        @cache = cache
      end

      def for(list)
        @cache[@name, list]
      end
    end
  end
end
