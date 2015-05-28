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

  test "pivoted_keys" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine::ArrayMiner.new(list)
    data = list.pivot("less than 5") { |i| i < 5 }
    expected = ["less than 5"]
    assert data.pivoted_keys == expected
  end

  test "to_a tabular data" do
    list = [
      { :name => "Sally",   :age => 21 },
      { :name => "John",    :age => 28 },
      { :name => "Stephen", :age => 37 },
      { :name => "Emily",   :age => 32 },
      { :name => "Joe",     :age => 18 }
    ]
    list = Goldmine::ArrayMiner.new(list)
    mined = list.pivot("Name has an 'e'") do |record|
      !!record[:name].match(/e/i)
    end
    mined = mined.pivot(">= 21 years old") do |record|
      record[:age] >= 21
    end

    expected = [["Name has an 'e'", ">= 21 years old", "total"], [true, false, 1], [false, true, 2], [true, true, 2]]

    # block is sort_by
    tabular_data = mined.to_a do |row|
      [row[2], row[0] ? 1 : 0, row[1] ? 1 : 0]
    end

    assert tabular_data == expected
  end

  test "source_data" do
    list = [
      { :name => "Sally",   :age => 21 },
      { :name => "John",    :age => 28 },
      { :name => "Stephen", :age => 37 },
      { :name => "Emily",   :age => 32 },
      { :name => "Joe",     :age => 18 }
    ]
    list = Goldmine::ArrayMiner.new(list)
    mined = list.pivot("Name has an 'e'") do |record|
      !!record[:name].match(/e/i)
    end
    mined = mined.pivot(">= 21 years old") do |record|
      record[:age] >= 21
    end
    assert mined.source_data == list
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
    assert data.source_data == list
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

end
