require "pry-test"
require "coveralls"
Coveralls.wear!
require File.expand_path("../../lib/goldmine", __FILE__)

class TestGoldmine < PryTest::Test

  test "miner from array" do
    assert Goldmine.miner([]).is_a?(Goldmine::ArrayMiner)
  end

  test "miner from hash" do
    assert Goldmine.miner({}).is_a?(Goldmine::HashMiner)
  end

  test "miner from usupported object" do
    assert Goldmine.miner(Object.new).nil?
  end

  test "simple pivot" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot { |i| i < 5 }

    expected = {
      true  => [1, 2, 3, 4],
      false => [5, 6, 7, 8, 9]
    }

    assert data == expected
  end

  test "simple pivot rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot { |i| i < 5 }

    expected = {
      true => 4,
      false => 5
    }

    assert data.rollup == expected
  end

  test "simple pivot rollup as percentage" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot { |i| i < 5 }

    expected = {
      true => 0.44,
      false => 0.56
    }

    assert data.rollup(percentage: true) == expected
  end

  test "simple pivot to_tabular" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot { |i| i < 5 }

    expected = [
      [true, 4],
      [false, 5]
    ]

    assert data.to_tabular == expected
  end

  test "named pivot" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("less than 5") { |i| i < 5 }

    expected = {
      { "less than 5" => true }  => [1, 2, 3, 4],
      { "less than 5" => false } => [5, 6, 7, 8, 9]
    }

    assert data == expected
  end

  test "named pivot rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("less than 5") { |i| i < 5 }

    expected = {
      { "less than 5" => true }  => 4,
      { "less than 5" => false } => 5
    }

    assert data.rollup == expected
  end

  test "named pivot to_tabular" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("less than 5") { |i| i < 5 }

    expected = [
      ["less than 5", "count"],
      [true, 4],
      [false, 5]
    ]

    assert data.to_tabular == expected
  end

  test "pivot of list values" do
    list = [
      { :name => "one",   :list => [1] },
      { :name => "two",   :list => [1, 2] },
      { :name => "three", :list => [1, 2, 3] },
      { :name => "four",  :list => [1, 2, 3, 4] },
    ]
    list = Goldmine::ArrayMiner.new(list)
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

    assert data == expected
  end

  test "pivot of list values with empty list" do
    list = [
      { :name => "empty", :list => [] },
      { :name => "one",   :list => [1] },
      { :name => "two",   :list => [1, 2] },
      { :name => "three", :list => [1, 2, 3] },
      { :name => "four",  :list => [1, 2, 3, 4] },
    ]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot { |record| record[:list] }

    expected = {
      nil => [ {:name => "empty", :list => [] } ],
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

    assert data == expected
  end

  test "chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot { |i| i < 5 }.pivot { |i| i % 2 == 0 }

    expected = {
      [true, false]  => [1, 3],
      [true, true]   => [2, 4],
      [false, false] => [5, 7, 9],
      [false, true]  => [6, 8]
    }

    assert data == expected
  end

  test "chained pivots rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot { |i| i < 5 }.pivot { |i| i % 2 == 0 }

    expected = {
      [true, false]  => 2,
      [true, true]   => 2,
      [false, false] => 3,
      [false, true]  => 2
    }

    assert data.rollup == expected
  end

  test "chained pivots to_tabular" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot { |i| i < 5 }.pivot { |i| i % 2 == 0 }

    expected = [
      [true, false, 2],
      [true, true, 2],
      [false, false, 3],
      [false, true, 2]
    ]

    assert data.to_tabular == expected
  end

  test "deep chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list
      .pivot { |i| i < 3 }
      .pivot { |i| i < 6 }
      .pivot { |i| i < 9 }
      .pivot { |i| i % 2 == 0 }
      .pivot { |i| i % 3 == 0 }

    expected = {
      [true,  true,  true,  false, false] => [1],
      [true,  true,  true,  true,  false] => [2],
      [false, true,  true,  false, true]  => [3],
      [false, true,  true,  false, false] => [5],
      [false, true,  true,  true,  false] => [4],
      [false, false, true,  true,  true]  => [6],
      [false, false, true,  true,  false] => [8],
      [false, false, true,  false, false] => [7],
      [false, false, false, false, true]  => [9]
    }

    assert data == expected
  end

  test "named deep chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("a") { |i| i < 3 }.pivot("b") { |i| i < 6 }.pivot("c") { |i| i < 9 }.pivot("d") { |i| i % 2 == 0 }.pivot("e") { |i| i % 3 == 0 }

    expected = {
      {"a"=>true,  "b"=>true,  "c"=>true,  "d"=>false, "e"=>false} => [1],
      {"a"=>true,  "b"=>true,  "c"=>true,  "d"=>true,  "e"=>false} => [2],
      {"a"=>false, "b"=>true,  "c"=>true,  "d"=>false, "e"=>true}  => [3],
      {"a"=>false, "b"=>true,  "c"=>true,  "d"=>false, "e"=>false} => [5],
      {"a"=>false, "b"=>true,  "c"=>true,  "d"=>true,  "e"=>false} => [4],
      {"a"=>false, "b"=>false, "c"=>true,  "d"=>true,  "e"=>true}  => [6],
      {"a"=>false, "b"=>false, "c"=>true,  "d"=>true,  "e"=>false} => [8],
      {"a"=>false, "b"=>false, "c"=>true,  "d"=>false, "e"=>false} => [7],
      {"a"=>false, "b"=>false, "c"=>false, "d"=>false, "e"=>true}  => [9]
    }

    assert data == expected
  end

  test "named deep chained pivots rollup as percentage" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("a") { |i| i < 3 }.pivot("b") { |i| i < 6 }.pivot("c") { |i| i < 9 }.pivot("d") { |i| i % 2 == 0 }.pivot("e") { |i| i % 3 == 0 }

    expected = {
      {"a"=>true, "b"=>true, "c"=>true, "d"=>false, "e"=>false}   => 0.11,
      {"a"=>true, "b"=>true, "c"=>true, "d"=>true, "e"=>false}    => 0.11,
      {"a"=>false, "b"=>true, "c"=>true, "d"=>false, "e"=>true}   => 0.11,
      {"a"=>false, "b"=>true, "c"=>true, "d"=>false, "e"=>false}  => 0.11,
      {"a"=>false, "b"=>true, "c"=>true, "d"=>true, "e"=>false}   => 0.11,
      {"a"=>false, "b"=>false, "c"=>true, "d"=>true, "e"=>true}   => 0.11,
      {"a"=>false, "b"=>false, "c"=>true, "d"=>true, "e"=>false}  => 0.11,
      {"a"=>false, "b"=>false, "c"=>true, "d"=>false, "e"=>false} => 0.11,
      {"a"=>false, "b"=>false, "c"=>false, "d"=>false, "e"=>true} => 0.11
    }

    assert data.rollup(percentage: true) == expected
  end

  test "named chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("less than 5") { |i| i < 5 }.pivot("divisible by 2") { |i| i % 2 == 0 }

    expected = {
      { "less than 5" => true, "divisible by 2" => false } => [1, 3],
      { "less than 5" => true, "divisible by 2" => true}   => [2, 4],
      { "less than 5" => false, "divisible by 2" => false} => [5, 7, 9],
      { "less than 5" => false, "divisible by 2" => true}  => [6, 8]
    }

    assert data == expected
  end

  test "named chained pivots rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("less than 5") { |i| i < 5 }.pivot("divisible by 2") { |i| i % 2 == 0 }

    expected = {
      { "less than 5" => true, "divisible by 2" => false }  => 2,
      { "less than 5" => true, "divisible by 2" => true }   => 2,
      { "less than 5" => false, "divisible by 2" => false } => 3,
      { "less than 5" => false, "divisible by 2" => true }  => 2
    }

    assert data.rollup == expected
  end

  test "named chained pivots rollup as percentage" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("less than 5") { |i| i < 5 }.pivot("divisible by 2") { |i| i % 2 == 0 }

    expected = {
      {"less than 5"=>true, "divisible by 2"=>false}  => 0.22,
      {"less than 5"=>true, "divisible by 2"=>true}   => 0.22,
      {"less than 5"=>false, "divisible by 2"=>false} => 0.33,
      {"less than 5"=>false, "divisible by 2"=>true}  => 0.22
    }

    assert data.rollup(percentage: true) == expected
  end

  test "named chained pivots to tabular" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("less than 5") { |i| i < 5 }.pivot("divisible by 2") { |i| i % 2 == 0 }

    expected = [
      ["less than 5", "divisible by 2", "count"],
      [true, false, 2],
      [true, true, 2],
      [false, false, 3],
      [false, true, 2]
    ]

    assert data.to_tabular == expected
  end
end
