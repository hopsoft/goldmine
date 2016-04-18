require "pry-test"
require "coveralls"
Coveralls.wear!
SimpleCov.command_name "pry-test"
require File.expand_path("../../lib/goldmine", __FILE__)

class TestGoldmine < PryTest::Test

  test "simple pivot" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot { |i| i < 5 }

    expected = {
      [true]  => [1, 2, 3, 4],
      [false] => [5, 6, 7, 8, 9]
    }

    assert pivot.result.to_h == expected
  end

  test "simple pivot rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot { |i| i < 5 }
    rollup = pivot.result
      .rollup(:count) { |items| items.size }

    expected = {
      [true]  => [[:count, 4]],
      [false] => [[:count, 5]]
    }

    assert rollup.result == expected
  end

  test "pivot with chained rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot { |i| i < 5 }
    rolled = pivot.result
      .rollup(:count) { |items| items.size }
      .rollup(:div_by_3) { |items| items.keep_if { |i| i % 3 == 0 }.size }

    expected = {
      [true]  => [[:count, 4], [:div_by_3, 1]],
      [false] => [[:count, 5], [:div_by_3, 2]]
    }

    assert rolled.result == expected
  end

  #test "simple pivot rollup to_tabular" do
  #  list = [1,2,3,4,5,6,7,8,9]
  #  list = Goldmine::ArrayMiner.new(list)
  #  rolled = list.pivot { |i| i < 5 }.rollup(:count, &:size)

  #  expected = [
  #    ["column1", "count"],
  #    [true, 4],
  #    [false, 5]
  #  ]

  #  assert rolled.to_tabular == expected
  #end

  #test "simple pivot rollup to_csv_table" do
  #  list = [1,2,3,4,5,6,7,8,9]
  #  list = Goldmine::ArrayMiner.new(list)
  #  rolled = list.pivot { |i| i < 5 }.rollup(:count, &:size)
  #  csv = rolled.to_csv_table

  #  assert csv.headers == ["column1", "count"]
  #  assert csv.to_a == [["column1", "count"], [true, 4], [false, 5]]
  #end

  test "named pivot" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot("less than 5") { |i| i < 5 }

    expected = {
      [["less than 5", true]]  => [1, 2, 3, 4],
      [["less than 5", false]] => [5, 6, 7, 8, 9]
    }

    assert pivot.result.to_h == expected
  end

  test "named pivot rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot("less than 5") { |i| i < 5 }
    rolled = pivot.result.rollup(:count) { |row| row.size }

    expected = {
      [["less than 5", true]]  => [[:count, 4]],
      [["less than 5", false]] => [[:count, 5]]
    }

    assert rolled.result == expected
  end

  #test "named pivot rollup to_tabular" do
  #  list = [1,2,3,4,5,6,7,8,9]
  #  list = Goldmine::ArrayMiner.new(list)
  #  rolled = list.pivot("less than 5") { |i| i < 5 }.rollup(:count, &:size)

  #  expected = [
  #    ["less than 5", "count"],
  #    [true, 4],
  #    [false, 5]
  #  ]

  #  assert rolled.to_tabular == expected
  #end

  #test "pivot of list values" do
  #  list = [
  #    { :name => "one",   :list => [1] },
  #    { :name => "two",   :list => [1, 2] },
  #    { :name => "three", :list => [1, 2, 3] },
  #    { :name => "four",  :list => [1, 2, 3, 4] },
  #  ]
  #  list = Goldmine::ArrayMiner.new(list)
  #  data = list.pivot { |record| record[:list] }

  #  expected = {
  #    1 => [ { :name => "one",   :list => [1] },
  #           { :name => "two",   :list => [1, 2] },
  #           { :name => "three", :list => [1, 2, 3] },
  #           { :name => "four",  :list => [1, 2, 3, 4] } ],
  #    2 => [ { :name => "two",   :list => [1, 2] },
  #           { :name => "three", :list => [1, 2, 3] },
  #           { :name => "four",  :list => [1, 2, 3, 4] } ],
  #    3 => [ { :name => "three", :list => [1, 2, 3] },
  #           { :name => "four",  :list => [1, 2, 3, 4] } ],
  #    4 => [ { :name => "four",  :list => [1, 2, 3, 4] } ]
  #  }

  #  assert data == expected
  #end

  #test "pivot of list values with empty list" do
  #  list = [
  #    { :name => "empty", :list => [] },
  #    { :name => "one",   :list => [1] },
  #    { :name => "two",   :list => [1, 2] },
  #    { :name => "three", :list => [1, 2, 3] },
  #    { :name => "four",  :list => [1, 2, 3, 4] },
  #  ]
  #  list = Goldmine::ArrayMiner.new(list)
  #  data = list.pivot { |record| record[:list] }

  #  expected = {
  #    nil => [ {:name => "empty", :list => [] } ],
  #    1 => [ { :name => "one",   :list => [1] },
  #           { :name => "two",   :list => [1, 2] },
  #           { :name => "three", :list => [1, 2, 3] },
  #           { :name => "four",  :list => [1, 2, 3, 4] } ],
  #    2 => [ { :name => "two",   :list => [1, 2] },
  #           { :name => "three", :list => [1, 2, 3] },
  #           { :name => "four",  :list => [1, 2, 3, 4] } ],
  #    3 => [ { :name => "three", :list => [1, 2, 3] },
  #           { :name => "four",  :list => [1, 2, 3, 4] } ],
  #    4 => [ { :name => "four",  :list => [1, 2, 3, 4] } ]
  #  }

  #  assert data == expected
  #end

  test "chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot { |i| i < 5 }
      .pivot { |i| i % 2 == 0 }

    expected = {
      [true, false]  => [1, 3],
      [true, true]   => [2, 4],
      [false, false] => [5, 7, 9],
      [false, true]  => [6, 8]
    }

    assert pivot.result.to_h == expected
  end

  test "chained pivots rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot { |i| i < 5 }.pivot { |i| i % 2 == 0 }
    rolled = pivot.result.rollup(:count) { |row| row.size }

    expected = {
      [true, false]  => [[:count, 2]],
      [true, true]   => [[:count, 2]],
      [false, false] => [[:count, 3]],
      [false, true]  => [[:count, 2]]
    }

    assert rolled.result == expected
  end

  #test "chained pivots rollup to_tabular" do
  #  list = [1,2,3,4,5,6,7,8,9]
  #  list = Goldmine::ArrayMiner.new(list)
  #  rolled = list.pivot { |i| i < 5 }.pivot { |i| i % 2 == 0 }.rollup(:count, &:size)

  #  expected = [
  #    ["column1", "column2", "count"],
  #    [true, false, 2],
  #    [true, true, 2],
  #    [false, false, 3],
  #    [false, true, 2]
  #  ]

  #  assert rolled.to_tabular == expected
  #end

  test "deep chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
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

    assert pivot.result.to_h == expected
  end

  test "named chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("less than 5") { |i| i < 5 }
      .pivot("divisible by 2") { |i| i % 2 == 0 }

    expected = {
      [["less than 5", true],  ["divisible by 2", false]] => [1, 3],
      [["less than 5", true],  ["divisible by 2", true]]  => [2, 4],
      [["less than 5", false], ["divisible by 2", false]] => [5, 7, 9],
      [["less than 5", false], ["divisible by 2", true]]  => [6, 8]
    }

    assert pivot.result.to_h == expected
  end

  test "named deep chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("a") { |i| i < 3 }
      .pivot("b") { |i| i < 6 }
      .pivot("c") { |i| i < 9 }
      .pivot("d") { |i| i % 2 == 0 }
      .pivot("e") { |i| i % 3 == 0 }

    expected = {
      [["a", true],  ["b", true],  ["c", true],  ["d", false], ["e", false]] => [1],
      [["a", true],  ["b", true],  ["c", true],  ["d", true],  ["e", false]] => [2],
      [["a", false], ["b", true],  ["c", true],  ["d", false], ["e", true]]  => [3],
      [["a", false], ["b", true],  ["c", true],  ["d", false], ["e", false]] => [5],
      [["a", false], ["b", true],  ["c", true],  ["d", true],  ["e", false]] => [4],
      [["a", false], ["b", false], ["c", true],  ["d", true],  ["e", true]]  => [6],
      [["a", false], ["b", false], ["c", true],  ["d", true],  ["e", false]] => [8],
      [["a", false], ["b", false], ["c", true],  ["d", false], ["e", false]] => [7],
      [["a", false], ["b", false], ["c", false], ["d", false], ["e", true]]  => [9]
    }

    assert pivot.result.to_h == expected
  end

  test "named chained pivots rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("less than 5") { |i| i < 5 }
      .pivot("divisible by 2") { |i| i % 2 == 0 }
    rolled = pivot.result
      .rollup(:count) { |row| row.size }

    expected = {
      [["less than 5", true],  ["divisible by 2", false]] => [[:count, 2]],
      [["less than 5", true],  ["divisible by 2", true]]  => [[:count, 2]],
      [["less than 5", false], ["divisible by 2", false]] => [[:count, 3]],
      [["less than 5", false], ["divisible by 2", true]]  => [[:count, 2]]
    }

    assert rolled.result == expected
  end

  #test "named chained pivots rollup to tabular" do
  #  list = [1,2,3,4,5,6,7,8,9]
  #  list = Goldmine::ArrayMiner.new(list)
  #  rolled = list.pivot("less than 5") { |i| i < 5 }.pivot("divisible by 2") { |i| i % 2 == 0 }.rollup(:count, &:size)

  #  expected = [
  #    ["less than 5", "divisible by 2", "count"],
  #    [true, false, 2],
  #    [true, true, 2],
  #    [false, false, 3],
  #    [false, true, 2]
  #  ]

  #  assert rolled.to_tabular == expected
  #end

  #test "named & chained pivots with rollup to_csv_table" do
  #  list = [1,2,3,4,5,6,7,8,9]
  #  list = Goldmine::ArrayMiner.new(list)
  #  rolled = list.pivot("less than 5") { |i| i < 5 }.pivot("divisible by 2") { |i| i % 2 == 0 }.rollup(:count, &:size)
  #  csv = rolled.to_csv_table

  #  assert csv.to_a == rolled.to_tabular

  #  expected = ["less than 5", "divisible by 2", "count"]
  #  assert csv.headers == expected

  #  row = csv.first
  #  assert row["less than 5"] == true
  #  assert row["divisible by 2"] == false
  #  assert row ["count"] == 2
  #end

  #test "unnamed & chained pivots with rollup to rows" do
  #  list = [1,2,3,4,5,6,7,8,9]
  #  list = Goldmine::ArrayMiner.new(list)
  #  rolled = list
  #    .pivot { |i| i < 5 }
  #    .rollup(:count, &:size)
  #    .rollup(:evens) { |l| l.select { |i| i % 2 == 0 }.size }
  #    .rollup(:even_percentage) { |l| computed(:evens).for(l) / computed(:count).for(l).to_f }

  #  expected = [
  #    {"column1"=>true, "count"=>4, "evens"=>2, "even_percentage"=>0.5},
  #    {"column1"=>false, "count"=>5, "evens"=>2, "even_percentage"=>0.4}
  #  ]

  #  assert rolled.to_rows == expected
  #end

  #test "named & chained pivots with rollup to rows" do
  #  list = [1,2,3,4,5,6,7,8,9]
  #  list = Goldmine::ArrayMiner.new(list)
  #  rolled = list
  #    .pivot(:less_than_5) { |i| i < 5 }
  #    .rollup(:count, &:size)
  #    .rollup(:evens) { |l| l.select { |i| i % 2 == 0 }.size }
  #    .rollup(:even_percentage) { |l| computed(:evens).for(l) / computed(:count).for(l).to_f }

  #  expected = [
  #    {"less_than_5"=>true, "count"=>4, "evens"=>2, "even_percentage"=>0.5},
  #    {"less_than_5"=>false, "count"=>5, "evens"=>2, "even_percentage"=>0.4}
  #  ]

  #  assert rolled.to_rows == expected
  #end

end
