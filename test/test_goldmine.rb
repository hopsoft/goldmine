require "test/unit"
require "turn"
require File.join(File.dirname(__FILE__), "..", "lib", "goldmine")

class TestGoldmine < MiniTest::Unit::TestCase

  def test_simple_pivot
    list = [1,2,3,4,5,6,7,8,9]
    data = list.pivot { |i| i < 5 }

    expected = {
      true  => [1, 2, 3, 4],
      false => [5, 6, 7, 8, 9]
    }

    assert_equal expected, data
  end

  def test_named_pivot
    list = [1,2,3,4,5,6,7,8,9]
    data = list.pivot("less than 5") { |i| i < 5 }

    expected = {
      { "less than 5" => true }  => [1, 2, 3, 4],
      { "less than 5" => false } => [5, 6, 7, 8, 9]
    }

    assert_equal expected, data
  end

  def test_pivot_of_list_values
    list = [
      { :name => "one",   :list => [1] },
      { :name => "two",   :list => [1, 2] },
      { :name => "three", :list => [1, 2, 3] },
      { :name => "four",  :list => [1, 2, 3, 4] },
    ]
    data = list.pivot { |record| record[:list] }

    expected = {
      1 => [ { :name => "one",   :list => [1] },
             { :name => "two",   :list => [1, 2] },
             { :name => "three", :list => [1, 2, 3] },
             { :name => "four",  :list => [1, 2, 3, 4] } ],
      2 => [ { :name => "two",   :list => [1, 2] },
             { :name => "three", :list => [1, 2, 3] },
             { :name => "four",  :list => [1, 2, 3, 4] } ],
      3 => [ { :name => "three", :list => [1, 2, 3] },
             { :name => "four",  :list => [1, 2, 3, 4] } ],
      4 => [ { :name => "four",  :list => [1, 2, 3, 4] } ]
    }

    assert_equal expected, data
  end

  def test_chained_pivots
    list = [1,2,3,4,5,6,7,8,9]
    data = list.pivot { |i| i < 5 }.pivot { |i| i % 2 == 0 }

    expected = {
      [true, false]  => [1, 3],
      [true, true]   => [2, 4],
      [false, false] => [5, 7, 9],
      [false, true]  => [6, 8]
    }

    assert_equal expected, data
  end

  def test_deep_chained_pivots
    list = [1,2,3,4,5,6,7,8,9]
    data = list.pivot("a") { |i| i < 3 }.pivot("b") { |i| i < 6 }.pivot("c") { |i| i < 9 }.pivot("d") { |i| i % 2 == 0 }.pivot("e") { |i| i % 3 == 0 }

    expected1 = {
      {"a"=>true, "b"=>true, "c"=>true, "d"=>false, "e"=>false}=>[1],
      {"a"=>true, "b"=>true, "c"=>true, "d"=>true, "e"=>false}=>[2],
      {"a"=>false, "b"=>true, "c"=>true, "d"=>false, "e"=>true}=>[3],
      {"a"=>false, "b"=>true, "c"=>true, "d"=>false, "e"=>false}=>[5],
      {"a"=>false, "b"=>true, "c"=>true, "d"=>true, "e"=>false}=>[4],
      {"a"=>false, "b"=>false, "c"=>true, "d"=>true, "e"=>true}=>[6],
      {"a"=>false, "b"=>false, "c"=>true, "d"=>true, "e"=>false}=>[8],
      {"a"=>false, "b"=>false, "c"=>true, "d"=>false, "e"=>false}=>[7],
      {"a"=>false, "b"=>false, "c"=>false, "d"=>false, "e"=>true}=>[9]
    }

    assert_equal expected1, data
  end

  def test_named_chained_pivots
    list = [1,2,3,4,5,6,7,8,9]
    data = list.pivot("less than 5") { |i| i < 5 }.pivot("divisible by 2") { |i| i % 2 == 0 }

    expected = {
      { "less than 5" => true, "divisible by 2" => false } => [1, 3],
      { "less than 5" => true, "divisible by 2" => true}   => [2, 4],
      { "less than 5" => false, "divisible by 2" => false} => [5, 7, 9],
      { "less than 5" => false, "divisible by 2" => true}  => [6, 8]
    }

    assert_equal expected, data
  end



end
