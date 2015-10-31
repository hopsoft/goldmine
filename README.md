[![Lines of Code](http://img.shields.io/badge/lines_of_code-193-brightgreen.svg?style=flat)](http://blog.codinghorror.com/the-best-code-is-no-code-at-all/)
[![Code Status](http://img.shields.io/codeclimate/github/hopsoft/goldmine.svg?style=flat)](https://codeclimate.com/github/hopsoft/goldmine)
[![Dependency Status](http://img.shields.io/gemnasium/hopsoft/goldmine.svg?style=flat)](https://gemnasium.com/hopsoft/goldmine)
[![Build Status](http://img.shields.io/travis/hopsoft/goldmine.svg?style=flat)](https://travis-ci.org/hopsoft/goldmine)
[![Coverage Status](https://img.shields.io/coveralls/hopsoft/goldmine.svg?style=flat)](https://coveralls.io/r/hopsoft/goldmine?branch=master)
[![Downloads](http://img.shields.io/gem/dt/goldmine.svg?style=flat)](http://rubygems.org/gems/goldmine)

# Goldmine

Extract a wealth of information from Arrays & Hashes.

Goldmine is especially helpful when working with source data that is difficult to query.
e.g. CSV files, API results, etc...

## Uses

- Data mining
- Data transformation
- Data blending
- Data visualization prep
- CSV report generation

## Quick Start

```sh
gem install goldmine
```

```ruby
require "goldmine"
```

```ruby
list = [1,2,3,4,5,6,7,8,9]

Goldmine::ArrayMiner.new(list).pivot { |i| i < 5 }
```

```ruby
{
  true  => [1, 2, 3, 4],
  false => [5, 6, 7, 8, 9]
}
```

## Named Pivots

```ruby
list = [1,2,3,4,5,6,7,8,9]

Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
```

```ruby
{
  { :less_than_5 => true }  => [1, 2, 3, 4],
  { :less_than_5 => false } => [5, 6, 7, 8, 9]
}
```

## Array Value Pivots

```ruby
list = [
  { :name => "Sally",   :favorite_colors => [:blue] },
  { :name => "John",    :favorite_colors => [:blue, :green] },
  { :name => "Stephen", :favorite_colors => [:red, :pink, :purple] },
  { :name => "Emily",   :favorite_colors => [:orange, :green] },
  { :name => "Joe",     :favorite_colors => [:red] }
]

Goldmine::ArrayMiner.new(list)
  .pivot { |record| record[:favorite_colors] }
```

```ruby
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

## Chained pivots

```ruby
list = [
  { :name => "Sally",   :age => 21 },
  { :name => "John",    :age => 28 },
  { :name => "Stephen", :age => 37 },
  { :name => "Emily",   :age => 32 },
  { :name => "Joe",     :age => 18 }
]

Goldmine::ArrayMiner.new(list)
  .pivot("Name has an 'e'") { |record|
    !!record[:name].match(/e/i)
  }
  .pivot(">= 21 years old") { |record|
    record[:age] >= 21
  }
```

```ruby
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
```

```ruby
{
  { :less_than_5 => true, :even => false }  => { :count => 2 },
  { :less_than_5 => true, :even => true }   => { :count => 2 },
  { :less_than_5 => false, :even => false } => { :count => 3 },
  { :less_than_5 => false, :even => true }  => { :count => 2 }
}
```

### Pre-Computed Results

Rollups can be computationally expensive _(depending upon how much logic you stuff into the `block`)_.
Goldmine caches rollup results & makes them available to subsequent rollups.

```ruby
list = [1,2,3,4,5,6,7,8,9]

Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .rollup(:count, &:size)
  .rollup(:evens) { |list| list.select { |i| i % 2 == 0 }.size }
  .rollup(:even_percentage) { |list|
    computed(:evens).for(list) / computed(:count).for(list).to_f
  }
```

```ruby
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
  .rollup(:even_percentage) { |list|
    computed(:evens).for(list) / computed(:count).for(list).to_f
  }
  .to_rows
```

```ruby
[
  { "less_than_5" => true, "count" => 4, "evens" => 2, "even_percentage" => 0.5 },
  { "less_than_5" => false, "count" => 5, "evens" => 2, "even_percentage" => 0.4 }
]
```

### Tabular

Rollups can also be converted into tabular format.

```ruby
list = [1,2,3,4,5,6,7,8,9]

Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .pivot(:even) { |i| i % 2 == 0 }
  .rollup(:count) { |matched| matched.size }
  .to_tabular
```

```ruby
[
  ["less_than_5", "even", "count"],
  [true, false, 2],
  [true, true, 2],
  [false, false, 3],
  [false, true, 2]
]
```

### CSV

Goldmine makes producing CSV output simple.

```ruby
list = [1,2,3,4,5,6,7,8,9]

csv_table = Goldmine::ArrayMiner.new(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .pivot(:even) { |i| i % 2 == 0 }
  .rollup(:count) { |matched| matched.size }
  .to_csv_table
```

```ruby
#<CSV::Table mode:col_or_row row_count:5>
```

```ruby
csv_table.to_csv
```

```ruby
"less_than_5,even,count\ntrue,false,2\ntrue,true,2\nfalse,false,3\nfalse,true,2\n"
```

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

In this example, we mine the following data.

* Total hotspots by city, zip, & area code
* Free hotspots by city, zip, & area code
* Paid hotspots by city, zip, & area code
* Library hotspots by city, zip, & area code
* Starbucks hotspots by city, zip, & area code
* McDonalds hotspots by city, zip, & area code

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

### [Medicare Physician Comparison](https://github.com/hopsoft/goldmine/tree/master/examples/medicare_physician_compare)

Uses data from http://dev.socrata.com/foundry/#/data.medicare.gov/aeay-dfax

In this example, we mine the following data.

* Total doctors by state & specialty
* Preferred doctors by state & specialty
* Female doctors by state & specialty
* Male doctors by state & specialty
* Preferred female doctors by state & specialty
* Preferred male doctors by state & specialty

```sh
ruby examples/medicare_physician_compare/app.rb
```

```sh
curl http://localhost:3000/raw
curl http://localhost:3000/pivoted
curl http://localhost:3000/rolled_up
curl http://localhost:3000/rows
curl http://localhost:3000/tabular
curl http://localhost:3000/csv
```

#### Performance

The Medicare dataset is large & works well for performance testing.

My Macbook Pro yields the following benchmarks.

* 3.1 GHz Intel Core i7
* 16 GB 1867 MHz DDR3

##### 100,000 Records

```
                      user     system      total        real
pivoted           1.000000   0.020000   1.020000 (  1.027810)
rolled_up         1.090000   0.020000   1.110000 (  1.101082)
rows              0.020000   0.000000   0.020000 (  0.022978)
tabular           0.010000   0.000000   0.010000 (  0.005423)
csv               0.030000   0.000000   0.030000 (  0.037245)
```

##### 1,000,000 Records

```
                      user     system      total        real
pivoted          15.700000   0.490000  16.190000 ( 16.886677)
rolled_up         7.070000   0.350000   7.420000 (  7.544060)
rows              0.020000   0.000000   0.020000 (  0.028432)
tabular           0.010000   0.010000   0.020000 (  0.007663)
csv               0.050000   0.000000   0.050000 (  0.058925)
```

## Summary

Goldmine makes data highly malleable.
It allows you to combine the power of pivots, rollups, tabular data,
& csv to construct deep insights with minimal effort.

Real world use cases include:

* Build a better understanding of database data before canonizing reports in SQL
* Create source data for building user interfaces & data visualizations
* Transform CSV data from one format to another
