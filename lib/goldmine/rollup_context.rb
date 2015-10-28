module Goldmine
  class RollupContext
    def initialize(cache)
      @cache = cache
      @computations = {}
    end

    def computed(name)
      name = name.to_sym
      @computations[name] ||= Computation.new(name, @cache)
    end

    class Computation
      attr_reader :name

      def initialize(name, cache)
        @name = name
        @cache = cache
      end

      def for(list)
        @cache.read(name, list)
      end
    end
  end
end
