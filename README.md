[![Lines of Code](http://img.shields.io/badge/lines_of_code-132-brightgreen.svg?style=flat)](http://blog.codinghorror.com/the-best-code-is-no-code-at-all/)
[![Code Status](http://img.shields.io/codeclimate/github/hopsoft/goldmine.svg?style=flat)](https://codeclimate.com/github/hopsoft/goldmine)
[![Dependency Status](http://img.shields.io/gemnasium/hopsoft/goldmine.svg?style=flat)](https://gemnasium.com/hopsoft/goldmine)
[![Build Status](http://img.shields.io/travis/hopsoft/goldmine.svg?style=flat)](https://travis-ci.org/hopsoft/goldmine)
[![Coverage Status](https://img.shields.io/coveralls/hopsoft/goldmine.svg?style=flat)](https://coveralls.io/r/hopsoft/goldmine?branch=master)
[![Downloads](http://img.shields.io/gem/dt/goldmine.svg?style=flat)](http://rubygems.org/gems/goldmine)

# Goldmine

Extract a wealth of information from Arrays & Hashes.
Think of __Goldmine__ as `Enumerable#group_by` on steroids.

## Uses

- Data mining
- Data transformation
- Data blending
- Data visualization prep
- CSV report generation

## Examples

All examples are simple Sinatra apps.
They are designed to help communicate Goldmine use-cases.

### Setup

```sh
git clone git@github.com:hopsoft/goldmine.git
cd /path/to/goldmine
bundle
```

### [New York Wifi Hotspots](https://github.com/hopsoft/goldmine/tree/master/examples/new_york_wifi_hotspots)

```sh
ruby examples/new_york_wifi_hotspots/app.rb
```

```sh
curl http://localhost:3000/raw
curl http://localhost:3000/pivoted
curl http://localhost:3000/rolled_up
curl http://localhost:3000/rows
curl http://localhost:3000/tabular
curl http://localhost:3000/csv
```

## Quick Start

```sh
gem install goldmine
```

```ruby
require "goldmine"

list = [1,2,3,4,5,6,7,8,9]
Goldmine::ArrayMiner.new(list)
  .pivot { |i| i < 5 }
# result:
{
  true  => [1, 2, 3, 4],
  false => [5, 6, 7, 8, 9]
}
```

## Chained Pivots

```ruby
list = [1,2,3,4,5,6,7,8,9]
Goldmine::ArrayMiner.new(list)
  .pivot { |i| i < 5 }
  .pivot { |i| i % 2 == 0 }
# result:
{
  [true, false]  => [1, 3],
  [true, true]   => [2, 4],
  [false, false] => [5, 7, 9],
  [false, true]  => [6, 8]
}
```

## Named Pivots

```ruby
list = [1,2,3,4,5,6,7,8,9]
Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
# result:
{
  { :less_than_5 => true }  => [1, 2, 3, 4],
  { :less_than_5 => false } => [5, 6, 7, 8, 9]
}
```

## Value Pivots

```ruby
list = [
  { :name => "Sally",   :favorite_colors => [:blue] },
  { :name => "John",    :favorite_colors => [:blue, :green] },
  { :name => "Stephen", :favorite_colors => [:red, :pink, :purple] },
  { :name => "Emily",   :favorite_colors => [:orange, :green] },
  { :name => "Joe",     :favorite_colors => [:red] }
]
list = Goldmine::ArrayMiner.new(list)
list.pivot { |record| record[:favorite_colors] }
# result:
{
  :blue => [
    { :name => "Sally", :favorite_colors => [:blue] },
    { :name => "John",  :favorite_colors => [:blue, :green] }
  ],
  :green => [
    { :name => "John",  :favorite_colors => [:blue, :green] },
    { :name => "Emily", :favorite_colors => [:orange, :green] }
  ],
  :red => [
    { :name => "Stephen", :favorite_colors => [:red, :pink, :purple] },
    { :name => "Joe",     :favorite_colors => [:red] }
  ],
  :pink => [
    { :name => "Stephen", :favorite_colors => [:red, :pink, :purple] }
  ],
  :purple => [
    { :name => "Stephen", :favorite_colors => [:red, :pink, :purple] }
  ],
  :orange => [
    { :name => "Emily", :favorite_colors => [:orange, :green] }
  ]
}
```

## Stacked pivots

```ruby
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
# result:
{
  { "Name has an 'e'" => false, ">= 21 years old" => true } => [
    { :name => "Sally", :age => 21 },
    { :name => "John",  :age => 28 }
  ],
  { "Name has an 'e'" => true, ">= 21 years old" => true } => [
    { :name => "Stephen", :age => 37 },
    { :name => "Emily",   :age => 32 }
  ],
  { "Name has an 'e'" => true, ">= 21 years old" => false } => [
    { :name => "Joe", :age => 18 }
  ]
}
```

## Rollups

Rollups provide a clean way to aggregate pivoted data...
think computed columns.

Rollup `blocks` are executed once for each pivot.
_Like pivots, rollups can be chained._

```ruby
list = [1,2,3,4,5,6,7,8,9]
Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .pivot(:even) { |i| i % 2 == 0 }
  .rollup(:count) { |matched| matched.size }
# result:
{
  { :less_than_5 => true, :even => false }  => { :count => 2 },
  { :less_than_5 => true, :even => true }   => { :count => 2 },
  { :less_than_5 => false, :even => false } => { :count => 3 },
  { :less_than_5 => false, :even => true }  => { :count => 2 }
}

### Pre-Computed Results

Rollups may be computationally expensive.
Goldmine caches rollup results & makes the results available to subsequent rollups.

```ruby
list = [1,2,3,4,5,6,7,8,9]
Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .rollup(:count, &:size)
  .rollup(:evens) { |list| list.select { |i| i % 2 == 0 }.size }
  .rollup(:even_percentage) { |list| computed(:evens).for(list) / computed(:count).for(list).to_f }
# result:
{
  { :less_than_5 => true } => { :count => 4, :evens => 2, :even_percentage => 0.5 },
  { :less_than_5 => false } => { :count => 5, :evens => 2, :even_percentage => 0.4 }
}
```

### Rows

It's often helpful to flatten rollups into rows.

```ruby
list = [1,2,3,4,5,6,7,8,9]
Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .rollup(:count, &:size)
  .rollup(:evens) { |list| list.select { |i| i % 2 == 0 }.size }
  .rollup(:even_percentage) { |list| computed(:evens).for(list) / computed(:count).for(list).to_f }
  .to_rows
# result:
[
  { "less_than_5" => true, "count" => 4, "evens" => 2, "even_percentage" => 0.5 },
  { "less_than_5" => false, "count" => 5, "evens" => 2, "even_percentage" => 0.4 }
]
```

### Tabular

Rollups can be converted into tabular format also.

```ruby
list = [1,2,3,4,5,6,7,8,9]
Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .pivot(:even) { |i| i % 2 == 0 }
  .rollup(:count) { |matched| matched.size }
  .to_tabular
# result:
[
  ["less_than_5", "even", "count"],
  [true, false, 2],
  [true, true, 2],
  [false, false, 3],
  [false, true, 2]
]
```

### CSV

Goldmine make producing CSV output simple.

```ruby
csv_table = Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .pivot(:even) { |i| i % 2 == 0 }
  .rollup(:count) { |matched| matched.size }
  .to_csv_table
# result:
#<CSV::Table mode:col_or_row row_count:5>

csv_table.to_csv
# result:
"less_than_5,even,count\ntrue,false,2\ntrue,true,2\nfalse,false,3\nfalse,true,2\n"
```

## Summary

Goldmine allows you to combine the power of pivots, rollups, tabular data,
& csv to construct deep insights into your data with minimal effort.

One of our common use cases is to query a database using ActiveRecord,
chain several pivots, chain several rollups, & then output JSON, CSV, & data visualizations.

