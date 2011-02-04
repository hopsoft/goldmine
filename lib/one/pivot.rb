# Namespace module for One on One Marketing.
module One

  # Class that can be used for mining data from lists of objects.
  class Pivot
    attr_accessor :multi_pivot_delimiter

    def initialize
      @multi_pivot_delimiter = "[PIVOT]"
    end

    # Pivots a list of Objects grouping them into an organized Hash.
    #
    # @example Pivot a list of numbers
    #   list = [1,2,3,4,5,6,7,8,9]
    #   result = pivot(list) {|num| num <=5 }
    #   result.inspect # => {false=>[6, 7, 8, 9], true=>[1, 2, 3, 4, 5]}
    #
    # @param [Array<Object>] list The list to pivot
    # @returns [Hash] The pivoted pivoted
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

