# Goldmine

## Data mining made easy... the Ruby way.
### Turn any list into a treasure trove.

Goldmine allows you to apply pivot table logic to any list for powerful data mining capabilities.

In the nomenclature of Goldmine, we call this digging for data. So we've added a `dig` method to `Array`.

### Reasons to love it

* Provides ETL like functionality... but simple and elegant
* Supports method chaining for deep data mining
* Handles values that are lists themselves
* Allows you to name your pivots

### Quick start

Install

```
$gem install goldmine
```

Usage

```ruby
[1,2,3,4,5,6,7,8,9].dig { |i| i < 5 }
```

### Usage examples

* [Pivot a list](#pivot-a-list-of-numbers-based-on-whether-or-not-they-are-less-than-5)
* [Create a named pivot](#explicitly-name-a-pivot)
* [Pivot values that are lists themselves](#pivot-values-that-are-lists-themselves)
* [Chain pivots](#chain-pivots-together)
* [Chain pivots conditionally](#conditionally-chain-pivots-together)
* Dig deep and extract meaningful data

## The Basics

### Pivot a list of numbers based on whether or not they are less than 5

```ruby
# operation
list = [1,2,3,4,5,6,7,8,9]
data = list.dig { |i| i < 5 }

# resulting data
{
  true  => [1, 2, 3, 4],
  false => [5, 6, 7, 8, 9]
}
```

### Explicitly name a pivot

```ruby
# operation
list = [1,2,3,4,5,6,7,8,9]
data = list.dig("less than 5") { |i| i < 5 }

# resulting data
{
  "less than 5: true"  => [1, 2, 3, 4],
  "less than 5: false" => [5, 6, 7, 8, 9]
}
```

## Next Steps

### Pivot values that are lists themselves

```ruby
# operation
list = [
  { :name => "one",   :list => [1] },
  { :name => "two",   :list => [1, 2] },
  { :name => "three", :list => [1, 2, 3] },
  { :name => "four",  :list => [1, 2, 3, 4] },
]
data = list.dig { |record| record[:list] }

# resulting data
{
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
```

### Chain pivots together

```ruby
# operation
list = [1,2,3,4,5,6,7,8,9]
data = list.dig { |i| i < 5 }.dig { |i| i % 2 == 0 }

# resulting data
{
  [true, false]  => [1, 3],
  [true, true]   => [2, 4],
  [false, false] => [5, 7, 9],
  [false, true]  => [6, 8]
}
```

### Conditionally chain pivots together

```ruby
# operation
params = { :divisible_by_two => false, :next_greater_than_five => true }
list = [1,2,3,4,5,6,7,8,9]
data = list.dig("less than 5") { |i| i < 5 }
data = data.dig("divisible by 2") { |i| i % 2 == 0 } if params[:divisible_by_two]
data = data.dig("next greater than 5") { |i| i.next > 5 } if params[:next_greater_than_five]

# resulting data
{
  ["less than 5: true", "next greater than 5: false"] => [1, 2, 3, 4],
  ["less than 5: false", "next greater than 5: true"] => [5, 6, 7, 8, 9]
}
```

## Deep Cuts




#### Pivot a list of users based on lang and number of projects owned

```ruby
list = [
  { :name => "Nathan",  :langs => [:ruby, :javascript],          :projects => [:a, :b] },
  { :name => "Eric",    :langs => [:ruby, :javascript, :groovy], :projects => [:a, :d, :g] },
  { :name => "Brian",   :langs => [:ruby, :javascript, :c, :go], :projects => [:b, :c, :e, :f] },
  { :name => "Mark",    :langs => [:ruby, :java, :scala],        :projects => [:g] },
  { :name => "Josh",    :langs => [:ruby, :lisp, :clojure],      :projects => [:a, :c] },
  { :name => "Matthew", :langs => [:ruby, :c, :clojure],         :projects => [:b, :c, :d] }
]
data = list
  .dig("lang") { |rec| rec[:langs] }
  .dig("project count") { |rec| rec[:projects].length }

# {
#   ["lang: ruby", "project count: 2"]       => [ { :name => "Nathan", ... }, { :name => "Josh", ... } ],
#   ["lang: ruby", "project count: 3"]       => [ { :name => "Eric", ... }, { :name => "Matthew", ... } ],
#   ["lang: ruby", "project count: 4"]       => [ { :name => "Brian", ... } ],
#   ["lang: ruby", "project count: 1"]       => [ { :name => "Mark", ... } ],
#   ["lang: javascript", "project count: 2"] => [ { :name => "Nathan", ... } ],
#   ["lang: javascript", "project count: 3"] => [ { :name => "Eric", ... } ],
#   ["lang: javascript", "project count: 4"] => [ { :name => "Brian", ... } ],
#   ["lang: groovy", "project count: 3"]     => [ { :name => "Eric", ... } ],
#   ["lang: c", "project count: 4"]          => [ { :name => "Brian", ... } ],
#   ["lang: c", "project count: 3"]          => [ { :name => "Matthew", ... } ],
#   ["lang: go", "project count: 4"]         => [ { :name => "Brian", ... } ],
#   ["lang: java", "project count: 1"]       => [ { :name => "Mark", ... } ],
#   ["lang: scala", "project count: 1"]      => [ { :name => "Mark", ... } ],
#   ["lang: lisp", "project count: 2"]       => [ { :name => "Josh", ... } ],
#   ["lang: clojure", "project count: 2"]    => [ { :name => "Josh", ... } ],
#   ["lang: clojure", "project count: 3"]    => [ { :name => "Matthew", ... } ]
# }
```

#### Pivot a list of users based on whether or not they know javascript, what other languages they know, and whether or not their name contains the letter 'a'

*Pretty contrived example here, but hopefully illustrates the type of power thats available.*

```ruby
list = [
  { :name => "Nathan",  :langs => [:ruby, :javascript],          :projects => [:a, :b] },
  { :name => "Eric",    :langs => [:ruby, :javascript, :groovy], :projects => [:a, :d, :g] },
  { :name => "Brian",   :langs => [:ruby, :javascript, :c, :go], :projects => [:b, :c, :e, :f] },
  { :name => "Mark",    :langs => [:ruby, :java, :scala],        :projects => [:g] },
  { :name => "Josh",    :langs => [:ruby, :lisp, :clojure],      :projects => [:a, :c] },
  { :name => "Matthew", :langs => [:ruby, :c, :clojure],         :projects => [:b, :c, :d] }
]
data = list
  .dig("knows javascript") { |rec| rec[:langs].include?(:javascript) }
  .dig("lang") { |rec| rec[:langs] }
  .dig("name includes 'a'") { |rec| rec[:name].include?("a") }

# {
#   ["knows javascript: true", "lang: ruby", "name includes 'a': true"]        => [ { :name => "Nathan", ... }, { :name => "Brian", ... } ],
#   ["knows javascript: true", "lang: ruby", "name includes 'a': false"]       => [ { :name => "Eric", ... } ],
#   ["knows javascript: true", "lang: javascript", "name includes 'a': true"]  => [ { :name => "Nathan", ... }, { :name => "Brian", ... } ],
#   ["knows javascript: true", "lang: javascript", "name includes 'a': false"] => [ { :name => "Eric", ... } ],
#   ["knows javascript: true", "lang: groovy", "name includes 'a': false"]     => [ { :name => "Eric", ... } ],
#   ["knows javascript: true", "lang: c", "name includes 'a': true"]           => [ { :name => "Brian", ... } ],
#   ["knows javascript: true", "lang: go", "name includes 'a': true"]          => [ { :name => "Brian", ... } ],
#   ["knows javascript: false", "lang: ruby", "name includes 'a': true"]       => [ { :name => "Mark", ... }, { :name => "Matthew", ... } ],
#   ["knows javascript: false", "lang: ruby", "name includes 'a': false"]      => [ { :name => "Josh", ... } ],
#   ["knows javascript: false", "lang: java", "name includes 'a': true"]       => [ { :name => "Mark", ... } ],
#   ["knows javascript: false", "lang: scala", "name includes 'a': true"]      => [ { :name => "Mark", ... } ],
#   ["knows javascript: false", "lang: lisp", "name includes 'a': false"]      => [ { :name => "Josh", ... } ],
#   ["knows javascript: false", "lang: clojure", "name includes 'a': false"]   => [ { :name => "Josh", ... } ],
#   ["knows javascript: false", "lang: clojure", "name includes 'a': true"]    => [ { :name => "Matthew", ... } ],
#   ["knows javascript: false", "lang: c", "name includes 'a': true"]          => [ { :name => "Matthew", ... } ]
# }
```
