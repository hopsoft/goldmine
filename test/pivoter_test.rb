require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'one', 'pivot'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'one', 'pivoter'))
require 'eventmachine'

class PivotTest < Test::Unit::TestCase

  context "A One::Pivot instance" do
    setup do
      @pivoter = One::Pivoter.new
    end

    should "pivot a simple array properly" do
      list = [1,2,3,4,5,6,7,8,9]
      result = @pivoter.pivot(list) {|item| item <= 5}
      assert_equal [6,7,8,9], result[false]
      assert_equal [1,2,3,4,5], result[true]
    end

    should "pivot inside of an existing EventMachine reactor" do
      EM.run do
        list = [1,2,3,4,5,6,7,8,9]
        result = @pivoter.pivot(list) {|item| item <= 5}
        sleep(0.01) # allow enough time for the pivot to complete
        assert_equal [6,7,8,9], result[false]
        assert_equal [1,2,3,4,5], result[true]
        EM.stop
      end
    end

    should "multi pivot a simple array properly" do
      list = [1,2,3,4,5,6,7,8,9]
      pivots = []

      pivots << lambda do |i|
        key = "less than or equal to 5" if i <= 5
        key ||= "greater than 5"
      end

      pivots << lambda do |i|
        key = "greater than or equal to 3" if i >= 3
        key ||= "less than 3"
      end

      pivots << {:delimiter => " & "}

      result = @pivoter.multi_pivot(list, *pivots)

      # the result will be a Hash with the following structure:
      hash = {
        "less than or equal to 5 & greater than or equal to 3" => [3, 4, 5],
        "less than or equal to 5 & less than 3" => [1, 2],
        "greater than 5 & greater than or equal to 3" => [6, 7, 8, 9]
      }

      assert_equal hash, result
    end

    should "support both procs and One::Pivot objects with multi_pivot" do
      list = [1,2,3,4,5,6,7,8,9]
      pivots = []

      pivots << One::Pivot.new("comparison to 5") do |i|
        key = "less than or equal to 5" if i <= 5
        key ||= "greater than 5"
      end

      pivots << One::Pivot.new("comparison to 3") do |i|
        key = "greater than or equal to 3" if i >= 3
        key ||= "less than 3"
      end

      pivots << {:delimiter => " & "}

      result = @pivoter.multi_pivot(list, *pivots)

      # the result will be a Hash with the following structure:
      hash = {
        "less than or equal to 5 & greater than or equal to 3" => [3, 4, 5],
        "less than or equal to 5 & less than 3" => [1, 2],
        "greater than 5 & greater than or equal to 3" => [6, 7, 8, 9]
      }

      assert_equal hash, result
    end

    should "support pivot observers (for example: to perform caching)" do
      # Pivot operations can be expensive.
      #
      # Demonstrate how you can use the observer pattern to cache
      # pivot results per item to save time on subsequent pivots for the same item.
      #
      # This strategy can be helpful if each item remains in memory for a period of time
      # that spans its participation in several pivot calls

      # extend Fixnum so we can cache pivot results
      Fixnum.class_eval do
        def pivot_cache
          @pivot_cache ||= {}
        end
      end

      assert 1.respond_to?(:pivot_cache)

      # create a pivot observer that caches pivot results per item
      class PivotObserver
        def initialize(pivoter)
          pivoter.add_observer(self)
        end

        # this method gets invoked by the pivot object whenever a pivot block is executed
        def update(identifier, item, value)
          item.pivot_cache[identifier] = value
        end
      end

      observer = PivotObserver.new(@pivoter)

      list = [1,2,3,4,5,6,7,8,9]
      result = @pivoter.pivot(list, :identifier => :less_than_5) do |item|
        if item.pivot_cache.has_key?(:less_than_5)
          raise Exception.new("Attempting to use a cached value that shouldn't exist")
        else
          item <= 5
        end
      end

      list.each do |item|
        assert item.pivot_cache.has_key?(:less_than_5)
      end

      # pivot again but this time use the pivot cache stored on each item
      cached_result = @pivoter.pivot(list, :identifier => :less_than_5) do |item|
        if item.pivot_cache.has_key?(:less_than_5)
          item.pivot_cache[:less_than_5]
        else
          raise Exception.new("Attempting to calculate a value that should be cached")
        end
      end

      assert_equal result, cached_result
    end

    should "support pivot observers when using multi_pivot (for example: to perform caching)" do
      # Pivot operations can be expensive.
      #
      # Demonstrate how you can use the observer pattern to cache
      # pivot results per item to save time on subsequent pivots for the same item.
      #
      # This strategy can be helpful if each item remains in memory for a period of time
      # that spans its participation in several pivot calls

      # extend Fixnum so we can cache pivot results
      Fixnum.class_eval do
        def pivot_cache
          @pivot_cache ||= {}
        end
      end

      assert 1.respond_to?(:pivot_cache)

      # create a pivot observer that caches pivot results per item
      class PivotObserver
        def initialize(pivoter)
          pivoter.add_observer(self)
        end

        # this method gets invoked by the pivot object whenever a pivot block is executed
        def update(identifier, item, value)
          item.pivot_cache[identifier] = value
        end
      end

      observer = PivotObserver.new(@pivoter)

      list = [1,2,3,4,5,6,7,8,9]

      pivots = []

      pivots << One::Pivot.new("comparison to 5") do |i|
        key = "less than or equal to 5" if i <= 5
        key ||= "greater than 5"
      end

      pivots << One::Pivot.new("comparison to 3") do |i|
        key = "greater than or equal to 3" if i >= 3
        key ||= "less than 3"
      end

      result = @pivoter.multi_pivot(list, *pivots)

      list.each do |item|
        assert item.pivot_cache.has_key?("comparison to 5")
        assert item.pivot_cache.has_key?("comparison to 3")
      end

      # pivot again but this time use the pivot cache stored on each item
      pivots = []

      pivots << One::Pivot.new("comparison to 5") do |i|
        i.pivot_cache["comparison to 5"]
      end

      pivots << One::Pivot.new("comparison to 3") do |i|
        i.pivot_cache["comparison to 3"]
      end

      cached_result = @pivoter.multi_pivot(list, *pivots)
      assert_equal result, cached_result
    end

    context "working on complex data structures" do

      setup do
        users = []
        users << {:name => "Frank", :gender => "M", :roles => []}
        users << {:name => "Joe", :gender => "M", :roles => []}
        users << {:name => "John", :gender => "M", :roles => []}
        users << {:name => "Sally", :gender => "F", :roles => []}

        # assign some roles to the users

        # Frank gets Read
        users[0][:roles] << "Read"

        # Joe gets Write
        users[1][:roles] << "Write"

        # John gets Read & Write
        users[2][:roles] << "Read"
        users[2][:roles] << "Write"

        # Sally gets no roles

        @users = users
      end

      should "pivot Array values individually using a nil key for empty Arrays" do
        result = @pivoter.pivot(@users) {|user| user[:roles]}

        # this is what the resulting hash should look like:
        hash = {
          nil => [
            {:name=>"Sally", :gender => "F", :roles=>[]}],
          "Read" => [
            {:name=>"Frank", :gender => "M", :roles=>["Read"]},
            {:name=>"John", :gender => "M", :roles=>["Read", "Write"]}],
          "Write" => [
            {:name=>"Joe", :gender => "M", :roles=>["Write"]},
            {:name=>"John", :gender => "M", :roles=>["Read", "Write"]}]
        }

        assert_equal hash, result
      end

      should "stack pivots with multi_pivot" do
        pivots = []
        pivots << lambda {|user| user[:gender]}
        pivots << lambda {|user| user[:roles]}

        result = @pivoter.multi_pivot(@users, *pivots)

        # this is what the resulting hash should look like
        hash = {
          "M[PIVOT]Write" => [
            {:name=>"Joe", :gender=>"M", :roles=>["Write"]},
            {:name=>"John", :gender=>"M", :roles=>["Read", "Write"]}],
          "M[PIVOT]Read" => [
            {:name=>"Frank", :gender=>"M", :roles=>["Read"]},
            {:name=>"John", :gender=>"M", :roles=>["Read", "Write"]}],
          "F[PIVOT]nil" => [
            {:name=>"Sally", :gender=>"F", :roles=>[]}]
        }

        assert_equal hash, result
      end

    end
  end
end
