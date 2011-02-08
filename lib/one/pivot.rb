module One

  # Simple class to hold meta information about a pivot.
  # This class was created to support invoking One::Pivot#multi_pivot with identifiers for each pivot.
  class Pivot
    attr_reader :identifier
    attr_reader :pivot_proc

    # Constructor.
    # param [String, Symbol] identifier The name of the pivot
    # @yield [item] This block will be called for each item in the list when pivot is invoked
    # @yieldparam [Object] item An item in the list
    # @yieldreturn [Object] The value returned from the pivot block will serve as the key in the pivot results
    def initialize(identifier, &block)
      raise LocalJumpError.new("no block given") unless block_given?
      @identifier = identifier
      @pivot_proc = block
    end
  end

end
