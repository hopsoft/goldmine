# Goldmine

## Data mining made easy... the Ruby way.
### Turn any list into a treasure trove.

Goldmine allows you to apply pivot table logic to any list for powerful data mining capabilities.

In the nomenclature of Goldmine, we call this digging for data. So... we've added a `dig` method to `Array`.

#### More reasons to love it

* ETL like functionality... but elegant
* Chain `digs` (or pivots) for deep data mining
* Support for values that are lists themselves

What does this all mean for you? Lets have a look at some examples.

## The Basics

#### Pivot a simple list of numbers based on whether or not they are less than 5

```ruby
list = [1,2,3,4,5,6,7,8,9]
data = list.dig { |i| i < 5 }

# {
#   true  => [1, 2, 3, 4],
#   false => [5, 6, 7, 8, 9]
# }
```

#### The same pivot as above but explicitly named

```ruby
list = [1,2,3,4,5,6,7,8,9]
data = list.dig("less than 5") { |i| i < 5 }

# {
#   "less than 5: true"  => [1, 2, 3, 4],
#   "less than 5: false" => [5, 6, 7, 8, 9]
# }
```

## Next Steps

#### Chain pivots together

```ruby
list = [1,2,3,4,5,6,7,8,9]
data = list.dig { |i| i < 5 }.dig { |i| i % 2 == 0 }

# {
#   [true, false]=>[1, 3],
#   [true, true]=>[2, 4],
#   [false, false]=>[5, 7, 9],
#   [false, true]=>[6, 8]
# }
```

#### The same pivot as above but explicitly named

```ruby
list = [1,2,3,4,5,6,7,8,9]
data = list.dig("less than 5") { |i| i < 5 }.dig("divisible by 2") { |i| i % 2 == 0 }

# {
#   ["less than 5: true", "divisible by 2: false"]=>[1, 3],
#   ["less than 5: true", "divisible by 2: true"]=>[2, 4],
#   ["less than 5: false", "divisible by 2: false"]=>[5, 7, 9],
#   ["less than 5: false", "divisible by 2: true"]=>[6, 8]
# }
```

## Deep Cuts
