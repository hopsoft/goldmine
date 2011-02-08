require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'one', 'pivot'))

class PivotTest < Test::Unit::TestCase

  context "A Pivot instance" do
 
    should "expect an identifier passed to construct" do
      assert_raise ArgumentError do
        One::Pivot.new
      end
    end
 
    should "expect a block to construct" do 
      assert_raise LocalJumpError do 
        One::Pivot.new :test
      end
    end

    should "store its name and pivot proc correctly" do 
      block = lambda {|item| item.class.name }
      instance = One::Pivot.new(:test, &block)
      assert_equal :test, instance.identifier      
      assert_equal block, instance.pivot_proc
    end

  end

end
