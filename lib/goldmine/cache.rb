module Goldmine
  class Cache

    def initialize
      @hash = {}
    end

    def [](*keys)
      @hash[make_key(*keys)]
    end

    def []=(*keys, value)
      @hash[make_key(*keys)] = value
    end

    def fetch(*keys)
      @hash[make_key(*keys)] ||= yield
    end

    private

    def make_key(*keys)
      keys.map do |key|
        key.is_a?(String) ? key.to_sym : key.object_id
      end
    end
  end
end
