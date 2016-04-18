require "forwardable"

module Goldmine
  class RollupResult
    extend Forwardable
    include Enumerable
    def_delegators :@hash, :[], :[]=, :each, :to_h

    def initialize(hash={})
      @hash = hash
    end

    def to_rows
    end

    private

  end
end
