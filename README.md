# Goldmine

## Data mining made easy... the Ruby way.
### Turn any list into a treasure trove.

Goldmine allows you to apply pivot table logic to any list for powerful data mining capabilities.

In the nomenclature of Goldmine, we call this digging for data. So... we've added a `dig` method to `Array`.

#### More reasons to love it

* ETL like functionality... but elegant
* Chain `digs` (or pivots) for deep data mining
* Support for values that are lists themselves

What does this all mean for you?

Lets have a look at some examples.

## The Basics

```ruby
# pivot a simple list of numbers
# based on whether or not they are less than 5
list = [1,2,3,4,5,6,7,8,9]
data = list.dig { |i| i < 5 }
# data is equal to
# {
#   true  => [1, 2, 3, 4],
#   false => [5, 6, 7, 8, 9]
# }
```

```ruby
# the same pivot as above but named
list = [1,2,3,4,5,6,7,8,9]
data = list.dig("less than 5") { |i| i < 5 }
# data is equal to
# {
#   "less than 5: true"  => [1, 2, 3, 4],
#   "less than 5: false" => [5, 6, 7, 8, 9]
# }
```

## Next Steps


## Deep Cuts
