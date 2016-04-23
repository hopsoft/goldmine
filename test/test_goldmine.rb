require "pry-test"
require "coveralls"
Coveralls.wear!
SimpleCov.command_name "pry-test"
require File.expand_path("../../lib/goldmine", __FILE__)

class TestGoldmine < PryTest::Test

  # pivots .....................................................................

  test "simple pivot" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot("< 5") { |i| i < 5 }

    expected = {
      [["< 5", true]]  => [1, 2, 3, 4],
      [["< 5", false]] => [5, 6, 7, 8, 9]
    }

    assert pivot.result.to_h == expected
  end

  test "chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("< 5") { |i| i < 5 }
      .pivot("even") { |i| i % 2 == 0 }

    expected = {
      [["< 5", true],  ["even", false]] => [1, 3],
      [["< 5", true],  ["even", true]]  => [2, 4],
      [["< 5", false], ["even", false]] => [5, 7, 9],
      [["< 5", false], ["even", true]]  => [6, 8]
    }

    assert pivot.result.to_h == expected
  end

  test "deep chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("< 3") { |i| i < 3 }
      .pivot("< 6") { |i| i < 6 }
      .pivot("< 9") { |i| i < 9 }
      .pivot("even") { |i| i % 2 == 0 }
      .pivot("odd") { |i| i % 3 == 0 || i == 1 }

    expected = {
      [["< 3", true],  ["< 6", true],  ["< 9", true],  ["even", false], ["odd", true]]  => [1],
      [["< 3", true],  ["< 6", true],  ["< 9", true],  ["even", true],  ["odd", false]] => [2],
      [["< 3", false], ["< 6", true],  ["< 9", true],  ["even", false], ["odd", true]]  => [3],
      [["< 3", false], ["< 6", true],  ["< 9", true],  ["even", true],  ["odd", false]] => [4],
      [["< 3", false], ["< 6", true],  ["< 9", true],  ["even", false], ["odd", false]] => [5],
      [["< 3", false], ["< 6", false], ["< 9", true],  ["even", true],  ["odd", true]]  => [6],
      [["< 3", false], ["< 6", false], ["< 9", true],  ["even", false], ["odd", false]] => [7],
      [["< 3", false], ["< 6", false], ["< 9", true],  ["even", true],  ["odd", false]] => [8],
      [["< 3", false], ["< 6", false], ["< 9", false], ["even", false], ["odd", true]]  => [9]
    }

    assert pivot.result.to_h == expected
  end

  test "pivot of list values" do
    list = [
      { :name => "one",   :list => [1] },
      { :name => "two",   :list => [1, 2] },
      { :name => "three", :list => [1, 2, 3] },
      { :name => "four",  :list => [1, 2, 3, 4] },
    ]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("list value") { |record| record[:list] }

    expected = {
      ["list value", 1] => [{:name=>"one", :list=>[1]}, {:name=>"two", :list=>[1, 2]}, {:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 2] => [{:name=>"two", :list=>[1, 2]}, {:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 3] => [{:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 4] => [{:name=>"four", :list=>[1, 2, 3, 4]}]
    }

    assert pivot.result.to_h == expected
  end

  test "pivot of list values with empty list" do
    list = [
      { :name => "empty", :list => [] },
      { :name => "one",   :list => [1] },
      { :name => "two",   :list => [1, 2] },
      { :name => "three", :list => [1, 2, 3] },
      { :name => "four",  :list => [1, 2, 3, 4] },
    ]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("list value") { |record| record[:list] }

    expected = {
      [["list value", nil]] => [{:name=>"empty", :list=>[]}],
      ["list value", 1]     => [{:name=>"one", :list=>[1]}, {:name=>"two", :list=>[1, 2]}, {:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 2]     => [{:name=>"two", :list=>[1, 2]}, {:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 3]     => [{:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 4]     => [{:name=>"four", :list=>[1, 2, 3, 4]}]
    }

    assert pivot.result.to_h == expected
  end

  # rollups ...................................................................

  test "simple pivot rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("< 5") { |i| i < 5 }
    rollup = pivot.result
      .rollup(:count) { |items| items.size }

    expected = {
      [["< 5", true]]  => [[:count, 4]],
      [["< 5", false]] => [[:count, 5]]
    }

    assert rollup.result.to_h == expected
  end

  test "chained pivots rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("< 5") { |i| i < 5 }
      .pivot("even") { |i| i % 2 == 0 }
    rolled = pivot.result
      .rollup(:count) { |row| row.size }

    expected = {
      [["< 5", true],  ["even", false]] => [[:count, 2]],
      [["< 5", true],  ["even", true]]  => [[:count, 2]],
      [["< 5", false], ["even", false]] => [[:count, 3]],
      [["< 5", false], ["even", true]]  => [[:count, 2]]
    }

    assert rolled.result.to_h == expected
  end

  test "pivot with chained rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("< 5") { |i| i < 5 }
    rolled = pivot.result
      .rollup(:count) { |items| items.size }
      .rollup(:div_by_3) { |items| items.keep_if { |i| i % 3 == 0 }.size }

    expected = {
      [["< 5", true]]  => [[:count, 4], [:div_by_3, 1]],
      [["< 5", false]] => [[:count, 5], [:div_by_3, 2]]
    }

    assert rolled.result.to_h == expected
  end

  # to_rows ...................................................................

  test "simple pivot rollup to_rows" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot("< 5") { |i| i < 5 }
    rollup = pivot.result
      .rollup(:count) { |items| items.size }

    expected = [
      [["< 5", true],  [:count, 4]],
      [["< 5", false], [:count, 5]]
    ]

    assert rollup.result.to_rows == expected
  end

  test "chained pivots rollup to_rows" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list
      .pivot("< 5") { |i| i < 5 }
      .pivot("even") { |i| i % 2 == 0 }
    rolled = pivot.result
      .rollup(:count) { |row| row.size }

    expected = [
      [["< 5", true],  ["even", false], [:count, 2]],
      [["< 5", true],  ["even", true],  [:count, 2]],
      [["< 5", false], ["even", false], [:count, 3]],
      [["< 5", false], ["even", true],  [:count, 2]]
    ]

    assert rolled.result.to_rows == expected
  end

  test "simple pivot rollup to_hash_rows" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    pivot = list.pivot("< 5") { |i| i < 5 }
    rollup = pivot.result
      .rollup(:count) { |items| items.size }

    expected = [
      {"< 5" => true,  :count => 4},
      {"< 5" => false, :count => 5}
    ]

    assert rollup.result.to_hash_rows == expected
  end

  # to_tabular ................................................................

  test "simple pivot rollup to_tabular" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    rollup = list
      .pivot("< 5") { |i| i < 5 }
      .result
      .rollup(:count, &:size)

    expected = [
      ["< 5", :count],
      [true, 4],
      [false, 5]
    ]

    assert rollup.result.to_tabular == expected
  end

  test "chained pivots rollup to_tabular" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    rollup = list
      .pivot("< 5") { |i| i < 5 }
      .pivot(:even) { |i| i % 2 == 0 }
      .result
      .rollup(:count, &:size)

    expected = [
      ["< 5", :even, :count],
      [true, false, 2],
      [true, true, 2],
      [false, false, 3],
      [false, true, 2]
    ]

    assert rollup.result.to_tabular == expected
  end

  # to_csv_table ..............................................................

  test "simple pivot rollup to_csv_table" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    rollup = list
      .pivot("< 5") { |i| i < 5 }
      .result
      .rollup(:count, &:size)

    csv = rollup.result.to_csv_table
    assert csv.to_s == "< 5,count\ntrue,4\nfalse,5\n"
  end

  # pivot_result cache ..........................................................

  test "pivot_result cache is available to rollups" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::Miner.new(list)
    cached_counts = []
    list
      .pivot("< 5") { |i| i < 5 }
      .result
      .rollup(:count, &:size)
      .rollup(:cached_count) { |hits| cached_counts << cache.read(:count, hits) }
      .result(cache: true)

    assert cached_counts.size == 2
    assert cached_counts.first == 4
    assert cached_counts.last == 5
  end

end
