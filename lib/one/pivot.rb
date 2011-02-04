module One
  module Pivot
    attr_accessor :multi_pivot_delimiter
    @multi_pivot_delimiter = "[PIVOT]"

    # Pivots a list of Objects grouping them into a sorted Hash.
    #
    # @example Pivot a list of numbers
    #   list = [1,2,3,4,5,6,7,8,9]
    #   result = pivot(list) {|num| num <=5 }
    #   result.inspect # => {false=>[6, 7, 8, 9], true=>[1, 2, 3, 4, 5]}
    #
    # @param [Array<Object>] list The list to pivot or sort
    # @returns [Hash] The pivoted results
    def pivot(list)
      pivoted = {}
      list.each do |item|
        value = yield(item)
  
        if value.is_a?(Array)
          has_value = false
          value.each do |val|
            has_value = true
            pivoted[val] ||= []
            pivoted[val] << item 
          end
          pivoted[nil] ||= []
          pivoted[nil] << item unless has_value
        else
          pivoted[value] ||= []
          pivoted[value] << item 
        end
      end

      pivoted
    end    

  end
end

