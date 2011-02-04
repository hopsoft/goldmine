require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'one', 'pivot'))

class Pivoter
  include One::Pivot
end

class PivotTest < Test::Unit::TestCase

  context "A class that mixes in One::Pivot" do
    setup do 
      @pivoter = Pivoter.new
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


  end

end
