[![Lines of Code](http://img.shields.io/badge/lines_of_code-193-brightgreen.svg?style=flat)](http://blog.codinghorror.com/the-best-code-is-no-code-at-all/)
[![Code Status](http://img.shields.io/codeclimate/github/hopsoft/goldmine.svg?style=flat)](https://codeclimate.com/github/hopsoft/goldmine)
[![Dependency Status](http://img.shields.io/gemnasium/hopsoft/goldmine.svg?style=flat)](https://gemnasium.com/hopsoft/goldmine)
[![Build Status](http://img.shields.io/travis/hopsoft/goldmine.svg?style=flat)](https://travis-ci.org/hopsoft/goldmine)
[![Coverage Status](https://img.shields.io/coveralls/hopsoft/goldmine.svg?style=flat)](https://coveralls.io/r/hopsoft/goldmine?branch=master)
[![Downloads](http://img.shields.io/gem/dt/goldmine.svg?style=flat)](http://rubygems.org/gems/goldmine)

# Goldmine

Extract a wealth of information from Arrays.

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

Goldmine(list)
  .pivot("< 5") { |i| i < 5 }
  .result
  .to_h
```

```ruby
{
  [["< 5", true]]  => [1, 2, 3, 4],
  [["< 5", false]] => [5, 6, 7, 8, 9]
}
```

## Array Value Pivots

```ruby
users = [
  { :name => "Sally",   :favorite_colors => [:blue] },
  { :name => "John",    :favorite_colors => [:blue, :green] },
  { :name => "Stephen", :favorite_colors => [:red, :pink, :purple] },
  { :name => "Emily",   :favorite_colors => [:orange, :green] },
  { :name => "Joe",     :favorite_colors => [:red] }
]

Goldmine(users)
  .pivot(:favorite_color) { |record| record[:favorite_colors] }
  .result
  .to_h
```

```ruby
{
  [:favorite_color, :blue]   => [{:name=>"Sally", :favorite_colors=>[:blue]}, {:name=>"John", :favorite_colors=>[:blue, :green]}],
  [:favorite_color, :green]  => [{:name=>"John", :favorite_colors=>[:blue, :green]}, {:name=>"Emily", :favorite_colors=>[:orange, :green]}],
  [:favorite_color, :red]    => [{:name=>"Stephen", :favorite_colors=>[:red, :pink, :purple]}, {:name=>"Joe", :favorite_colors=>[:red]}],
  [:favorite_color, :pink]   => [{:name=>"Stephen", :favorite_colors=>[:red, :pink, :purple]}],
  [:favorite_color, :purple] => [{:name=>"Stephen", :favorite_colors=>[:red, :pink, :purple]}],
  [:favorite_color, :orange] => [{:name=>"Emily", :favorite_colors=>[:orange, :green]}]
}
```

## Chained pivots

```ruby
users = [
  { :name => "Sally",   :age => 21 },
  { :name => "John",    :age => 28 },
  { :name => "Stephen", :age => 37 },
  { :name => "Emily",   :age => 32 },
  { :name => "Joe",     :age => 18 }
]

Goldmine(users).
  pivot("'e' in name") { |user| !!user[:name].match(/e/i) }.
  pivot("21 or over") { |user| user[:age] >= 21 }.
  result.
  to_h
```

```ruby
{
  [["'e' in name", false], ["21 or over", true]]  => [{:name=>"Sally", :age=>21}, {:name=>"John", :age=>28}],
  [["'e' in name", true],  ["21 or over", true]]  => [{:name=>"Stephen", :age=>37}, {:name=>"Emily", :age=>32}],
  [["'e' in name", true],  ["21 or over", false]] => [{:name=>"Joe", :age=>18}]
}
```

## Rollups

An intuitive way to aggregate pivoted data...
i.e. computed columns.

Rollups are `blocks` that get executed once for each pivot entry.
_They can be also be chained._

```ruby
list = [1,2,3,4,5,6,7,8,9]

Goldmine(list)
  .pivot("< 5") { |i| i < 5 }
  .pivot("even") { |i| i % 2 == 0 }
  .result
  .rollup("count", &:count)
  .result
  .to_h
```

```ruby
{
  [["< 5", true],  ["even", false]] => [["count", 2]],
  [["< 5", true],  ["even", true]]  => [["count", 2]],
  [["< 5", false], ["even", false]] => [["count", 3]],
  [["< 5", false], ["even", true]]  => [["count", 2]]
}
```

### Rollup Caching

Rollups can be computationally expensive.
Optional caching can be used to reduce this computational overhead.

```ruby
list = [1,2,3,4,5,6,7,8,9]

Goldmine(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .result
  .rollup(:count, &:count)
  .rollup(:evens) { |list| list.select { |i| i % 2 == 0 }.count }
  .rollup(:even_percentage) { |list| cache[:evens] / cache[:count].to_f }
  .result(cache: true)
  .to_h
```

```ruby
{
  [[:less_than_5, true]]  => [[:count, 4], [:evens, 2], [:even_percentage, 0.5]],
  [[:less_than_5, false]] => [[:count, 5], [:evens, 2], [:even_percentage, 0.4]]
}
```

### Rows

It's often helpful to flatten rollups into rows.

```ruby
list = [1,2,3,4,5,6,7,8,9]

rollup = Goldmine(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .result
  .rollup(:count, &:count)
  .rollup(:evens) { |list| list.select { |i| i % 2 == 0 }.count }
  .rollup(:even_percentage) { |list| cache[:evens] / cache[:count].to_f }
  .result(cache: true)
```

```ruby
rollup.to_rows
```

```ruby
[
  [[:less_than_5, true], [:count, 4], [:evens, 2], [:even_percentage, 0.5]],
  [[:less_than_5, false], [:count, 5], [:evens, 2], [:even_percentage, 0.4]]
]
```

```ruby
rollup.to_hash_rows
```

```ruby
[
  {:less_than_5=>true, :count=>4, :evens=>2, :even_percentage=>0.5},
  {:less_than_5=>false, :count=>5, :evens=>2, :even_percentage=>0.4}
]
```

### Tabular

Rollups can also be converted into tabular format.

```ruby
list = [1,2,3,4,5,6,7,8,9]

Goldmine(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .pivot(:even) { |i| i % 2 == 0 }
  .result
  .rollup(:count, &:size)
  .result
  .to_tabular
```

```ruby
[
  [:less_than_5, :even, :count],
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

Goldmine(list)
  .pivot(:less_than_5) { |i| i < 5 }
  .pivot(:even) { |i| i % 2 == 0 }
  .result
  .rollup(:count) { |matched| matched.size }
  .result
  .to_csv_table
  .to_csv
```

```ruby
"less_than_5,even,count\ntrue,false,2\ntrue,true,2\nfalse,false,3\nfalse,true,2\n"
```

## Example Apps

All examples are small Sinatra apps.
They are designed to help communicate Goldmine use-cases.

### Setup

```sh
git clone git@github.com:hopsoft/goldmine.git
cd /path/to/goldmine
bundle
```

### [New York Wifi Hotspots](https://github.com/hopsoft/goldmine/tree/master/examples/new_york_wifi_hotspots)

Uses data from https://github.com/hopsoft/goldmine/blob/master/examples/new_york_wifi_hotspots/DOITT_WIFI_HOTSPOT_01_13SEPT2010.csv

In this example, we mine out the following information.

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

In this example, we mine out the following information.

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
pivoted           0.630000   0.030000   0.660000 (  0.670409)
rolled_up         0.570000   0.030000   0.600000 (  0.626413)
rows              0.010000   0.000000   0.010000 (  0.003258)
tabular           0.010000   0.000000   0.010000 (  0.010110)
csv               0.050000   0.000000   0.050000 (  0.057677)
```

##### 1,000,000 Records

```
                      user     system      total        real
pivoted           7.270000   0.300000   7.570000 (  8.053166)
rolled_up         6.800000   0.830000   7.630000 (  8.051707)
rows              0.000000   0.000000   0.000000 (  0.003934)
tabular           0.010000   0.000000   0.010000 (  0.011825)
csv               0.210000   0.010000   0.220000 (  0.222752)
```

## Summary

Goldmine makes data highly malleable.
It allows you to combine the power of pivots, rollups, tabular data,
& csv to construct deep insights with minimal effort.

Real world use cases include:

* Build a better understanding of database data before canonizing reports in SQL
* Create source data for building user interfaces & data visualizations
* Transform CSV data from one format to another
