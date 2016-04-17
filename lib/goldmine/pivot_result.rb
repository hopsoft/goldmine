require "forwardable"

module Goldmine
  class PivotResult
    extend Forwardable
    include Enumerable
    def_delegators :@hash, :[], :[]=, :each, :to_h

    def initialize(hash={})
      @hash = hash
    end

  end
end
