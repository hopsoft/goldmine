module Goldmine
  class Cache
    def initialize
      @hash = {}
    end

    def read(*keys)
      @hash[make_key(*keys)]
    end

    def write(*keys, value)
      @hash[make_key(*keys)] = value
    end

    def fetch(*keys)
      @hash[make_key(*keys)] ||= yield
    end

    private

    def make_key(*keys)
      keys.map do |key|
        key = key.to_sym if key.is_a?(String)
        key.object_id
      end.join
    end
  end
end
