require 'rubygems'
require 'observer'
require 'eventmachine'
require 'thread'


# Namespace module for One on One Marketing.
module One

  # Class that can be used for mining data from lists of objects.
  class Pivoter
    include Observable

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
    # @param [optional, Hash] options Options to pivot with
    # @option options [Object] :identifier A name that uniquely identifies the pivot operation
    # @yield [item] The block passed to pivot will be called for each item in the list
    # @yieldparam [Object] item An item in the list
    # @yieldreturn [Object] The value returned from the pivot block will serve as the key in the pivot results
    # @return [Hash] The pivoted results
    def pivot(list, options={}, &block)
      pivoted = {}
      semaphore = Mutex.new

      lists = list.each_slice(chunk_size(list)).to_a
      loops = 0

      EM.run do
        lists.each do |sub_list|

          pivot_operation = Proc.new do
            sub_list.each do |item|
              # potential long running operation with blocking IO
              value = yield(item)

              # notify observers that a pivot block was just called
              identifier = options[:identifier] || "#{item.hash}:#{block.hash}"
              changed
              # potential long running operation with blocking IO
              notify_observers(identifier, item, value)

              semaphore.synchronize {
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
              }
            end
          end

          pivot_callback = Proc.new do
            semaphore.synchronize {
              loops += 1
              EM.stop if loops == lists.length
            }
          end

          EM.defer(pivot_operation, pivot_callback)
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
    #   # note the last pivot is an options Hash
    #   pivots << {:delimiter => " & "}
    #
    #   pivoter = One::Pivot.new
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
    # @param [Array<Proc, One::Pivot>] pivots An argument list that accepts N number of pivots.<br />
    #   The last pivot in the list can be an options Hash for the multi_pivot operation.<br />
    #   Supported options are:<br />
    #   * :delimiter, The delimiter to use between pivot keys.  Defaults to '[PIVOT]']
    # @return [Hash] The pivoted results
    def multi_pivot(list, *pivots)
      options = pivots.pop if pivots.last.is_a?(Hash)
      options ||= {}
      delimiter = options[:delimiter] || "[PIVOT]"
      pivoted = nil
      pass = 0

      while pivots.length > 0
        p = pivots.shift

        # handle the case where the pivots are One::Pivot objects
        pivot_options = {}
        if p.is_a?(One::Pivot)
          pivot_options[:identifier] = p.identifier
          p = p.pivot_proc
        end

        if pass == 0
          pivoted = pivot(list, pivot_options, &p)
        else
          new_pivoted = {}
          pivoted.each do |old_key, old_list|
            tmp_pivoted = pivot(old_list, pivot_options, &p)
            tmp_pivoted.each do |key, list|
              new_key = "#{safe_key(old_key)}#{delimiter}#{safe_key(key)}"
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

    def chunk_size(list)
      case list.length
      when 0..10 then 2
      when 10..100 then 5
      else 10
      end
    end

  end
end

