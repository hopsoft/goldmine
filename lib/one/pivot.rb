# Namespace module for One on One Marketing.
module One

  # Class that can be used for mining data from lists of objects.
  class Pivot
    attr_accessor :multi_pivot_delimiter

    def initialize(options={})
      @multi_pivot_delimiter = options[:multi_pivot_delimiter] || "[PIVOT]"
    end

    # Pivots a list of Objects grouping them into an organized Hash.
    #
    # @example Pivot a list of numbers into 2 groups, those less than or equal to 5 and those greater than 5
    #   list = [1,2,3,4,5,6,7,8,9]
    #   result = pivot(list) {|num| num <=5 }
    #
    #   # the result will be a Hash with the following structure
    #   {
    #     true=>[1, 2, 3, 4, 5],
    #     false=>[6, 7, 8, 9] 
    #   }
    #
    # @param [Array<Object>] list The list to pivot
    # @yield [item] The block/proc used to invoke pivot will yield for each item in the list 
    # @yieldparam [Object] item An item in the list
    # @yieldreturn [Object] The value returned from the pivot block/proc will serve as the key in the pivot results
    # @return [Hash] The pivoted results
    def pivot(list)
      pivoted = {}
      list.each do |item|
        value = yield(item)
  
        if value.is_a?(Array)
          if value.empty?
            pivoted[nil] ||= []
            pivoted[nil] << item 
          else
            value.each do |val|
              pivoted[val] ||= []
              pivoted[val] << item 
            end
          end
        else
          pivoted[value] ||= []
          pivoted[value] << item 
        end
      end

      pivoted
    end    

    # Runs multiple pivots against a list of Objects.
    #
    # @example Multi-pivot a list of numbers
    #   list = [1,2,3,4,5,6,7,8,9]
    #   pivots = []
    #
    #   pivots << lambda do |i|
    #     key = "less than or equal to 5" if i <= 5
    #     key ||= "greater than 5"
    #   end
    #
    #   pivots << lambda do |i|
    #     key = "greater than or equal to 3" if i >= 3
    #     key ||= "less than 3"
    #   end
    #    
    #   pivoter = One::Pivot.new(:multi_pivot_delimiter => " & ")
    #   result = pivoter.multi_pivot(list, *pivots) 
    #   
    #   # the result will be a Hash with the following structure
    #   {
    #     "less than or equal to 5 & greater than or equal to 3" => [3, 4, 5], 
    #     "less than or equal to 5 & less than 3" => [1, 2], 
    #     "greater than 5 & greater than or equal to 3" => [6, 7, 8, 9]
    #   }
    #
    # @param [Array<Object>] list The list to run the pivots against
    # @param [Array<Proc>] pivots An argument list that accepts N number of pivot procs
    # @return [Hash] The pivoted results
    def multi_pivot(list, *pivots)
      pivoted = nil
      pass = 0

      while pivots.length > 0
        p = pivots.shift

        if pass == 0
          pivoted = pivot(list, &p)
        else
          new_pivoted = {}
          pivoted.each do |old_key, old_list|
            tmp_pivoted = pivot(old_list, &p)
            tmp_pivoted.each do |key, list|
              new_key = "#{safe_key(old_key)}#{multi_pivot_delimiter}#{safe_key(key)}"
              new_pivoted[new_key] = list
            end
          end
          pivoted = new_pivoted
        end

        pass += 1
      end

      pivoted
    end

    private

    def safe_key(key)
      key = "nil" if key.to_s.strip.empty?
      key.to_s
    end

  end
end

