require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'one', 'pivot'))

class PivotTest < Test::Unit::TestCase

  context "A One::Pivot instance" do
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
