module Goldmine
  class RollupCache

    def initialize(cache={})
      @cache = cache
    end

    def read(name, list)
      @cache[cache_key(name, list)]
    end

    def write(name, list, value)
      @cache[cache_key(name, list)] = value
    end

    private

    def cache_key(name, list)
      "#{name}/#{list.object_id}"
    end

  end
end
