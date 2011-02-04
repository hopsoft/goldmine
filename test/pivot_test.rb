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
      users = []
      users << {:name => "Frank", :roles => []}
      users << {:name => "Joe", :roles => []}
      users << {:name => "John", :roles => []}
      users << {:name => "Sally", :roles => []}

      # assign some roles to the users

      # Frank gets Read
      users[0][:roles] << "Read"
     
      # Joe gets Write
      users[1][:roles] << "Write" 

      # John gets Read & Write
      users[2][:roles] << "Read" 
      users[2][:roles] << "Write"

      # Sally gets no roles

      result = @pivoter.pivot(users) do |user|
        user[:roles]
      end

      # this is what the resulting hash should look like:
      hash = {
        nil => [
          {:name=>"Sally", :roles=>[]}], 
        "Read" => [
          {:name=>"Frank", :roles=>["Read"]}, 
          {:name=>"John", :roles=>["Read", "Write"]}], 
        "Write" => [
          {:name=>"Joe", :roles=>["Write"]}, 
          {:name=>"John", :roles=>["Read", "Write"]}]
      }
      
      assert_equal hash, result
    end

  end
end
