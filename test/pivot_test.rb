require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'one', 'pivot'))

class PivotTest < Test::Unit::TestCase

  context "A class that mixes in One::Pivot" do
    setup do 
      @pivoter = One::Pivot.new
    end

    should "support a multi_pivot_delimiter" do
      assert @pivoter.respond_to?(:multi_pivot_delimiter)
      @pivoter.multi_pivot_delimiter = "[PIVOT]"
      assert_equal "[PIVOT]", @pivoter.multi_pivot_delimiter 
    end

    should "pivot a simple array properly" do
      list = [1,2,3,4,5,6,7,8,9]
      result = @pivoter.pivot(list) {|item| item <= 5}
      assert_equal [6,7,8,9], result[false]
      assert_equal [1,2,3,4,5], result[true] 
    end

    should "pivot Array values individually using a nil key for empty Arrays" do
      list = []
      list << [1, 2, 3]
      list << ["a", "b", "c"]
      list << ["apple", "airplane", "banana"]
      list << ["apple", 2, 3] 
      list << ["airplane", 2, 3] 
      result = @pivoter.pivot(list) do |entry|
        value = entry.select {|item| item =~ /^a/i}
        # value will be one of the following: [], ["a"], ["apple", "airplane"]
        # these values will act as the keys in pivoted hash
        # with the empty array mapping to nil
        # and ["apple", "airplane"] acting as two separate keys
        value
      end

      puts result.inspect

      # this is what the resulting hash should look like:
      hash = {
        nil=>[[1, 2, 3]], 
        "a"=>[["a", "b", "c"]], 
        "apple"=>[["apple", "airplane", "banana"], ["apple", 2, 3]], 
        "airplane"=>[["apple", "airplane", "banana"], ["airplane", 2, 3]]
      }

      assert_equal hash, result
    end
  end

end
