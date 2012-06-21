---
layout: main
---
# Goldmine {#goldmine}

## Pivot tables for the Rubyist {#pivot-tables-for-the-rubyist}

### Pivot any list into a wealth of information. {#pivot-any-list-into-a-wealth-of-information.}

Goldmine allows you to apply pivot table logic to any list for powerful data mining capabilities.

### Reasons to love it {#reasons-to-love-it}

* Provides ETL like functionality... but simple and elegant
* Easily build OLAP cubes using Ruby
* Supports method chaining for deep data mining
* Handles values that are lists themselves

[Why use it?](#putting-it-all-together)

## Quick start {#quick-start}

Install

{% highlight bash %}
$gem install goldmine
{% endhighlight %}

Use

{% highlight ruby %}
require "goldmine"
[1,2,3,4,5,6,7,8,9].pivot { |i| i < 5 }
{% endhighlight %}

### Usage examples {#usage-examples}

* [Pivot a list](#pivot-a-list-of-numbers-based-on-whether-or-not-they-are-less-than-5)
* [Create a named pivot](#explicitly-name-a-pivot)
* [Pivot values that are lists themselves](#pivot-values-that-are-lists-themselves)
* [Chain pivots](#chain-pivots-together)
* [Chain pivots conditionally](#conditionally-chain-pivots-together)
* [Dig deep and extract meaningful data](#deep-cuts)

## The Basics {#the-basics}

### Pivot a list of numbers based on whether or not they are less than 5 {#pivot-a-list-of-numbers-based-on-whether-or-not-they-are-less-than-5}

{% highlight ruby %}
# operation {#operation}
list = [1,2,3,4,5,6,7,8,9]
data = list.pivot { |i| i < 5 }

# resulting data {#resulting-data}
{
  true  => [1, 2, 3, 4],
  false => [5, 6, 7, 8, 9]
}
{% endhighlight %}

### Explicitly name a pivot {#explicitly-name-a-pivot}

{% highlight ruby %}
# operation {#operation}
list = [1,2,3,4,5,6,7,8,9]
data = list.pivot("less than 5") { |i| i < 5 }

# resulting data {#resulting-data}
{
  { "less than 5" => true }  => [1, 2, 3, 4],
  { "less than 5" => false } => [5, 6, 7, 8, 9]
}
{% endhighlight %}

## Next Steps {#next-steps}

### Pivot values that are lists themselves {#pivot-values-that-are-lists-themselves}

{% highlight ruby %}
# operation {#operation}
list = [
  { :name => "one",   :list => [1] },
  { :name => "two",   :list => [1, 2] },
  { :name => "three", :list => [1, 2, 3] },
  { :name => "four",  :list => [1, 2, 3, 4] },
]
data = list.pivot { |record| record[:list] }

# resulting data {#resulting-data}
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
{% endhighlight %}

### Chain pivots together {#chain-pivots-together}

{% highlight ruby %}
# operation {#operation}
list = [1,2,3,4,5,6,7,8,9]
data = list.pivot { |i| i < 5 }.pivot { |i| i % 2 == 0 }

# resulting data {#resulting-data}
{
  [true, false]  => [1, 3],
  [true, true]   => [2, 4],
  [false, false] => [5, 7, 9],
  [false, true]  => [6, 8]
}
{% endhighlight %}

### Conditionally chain pivots together {#conditionally-chain-pivots-together}

{% highlight ruby %}
# operation {#operation}
params = { :divisible_by_two => false, :next_greater_than_five => true }
list = [1,2,3,4,5,6,7,8,9]
data = list.pivot("less than 5") { |i| i < 5 }
data = data.pivot("divisible by 2") { |i| i % 2 == 0 } if params[:divisible_by_two]
data = data.pivot("next greater than 5") { |i| i.next > 5 } if params[:next_greater_than_five]

# resulting data {#resulting-data}
{
  { "less than 5" => true,  "next greater than 5" => false } => [1, 2, 3, 4],
  { "less than 5" => false, "next greater than 5" => true } => [5, 6, 7, 8, 9]
}
{% endhighlight %}

## Deep Cuts {#deep-cuts}

### Build a moderately complex dataset of Cities {#build-a-moderately-complex-dataset-of-cities}

{% highlight ruby %}
cities = [
  { :name => "San Francisco",
    :state => "CA",
    :population => 805235,
    :airlines => [ "Delta", "United", "SouthWest" ]
  },
  {
    :name => "Mountain View",
    :state => "CA",
    :population => 74066,
    :airlines => [ "SkyWest", "United", "SouthWest" ]
  },
  {
    :name => "Manhattan",
    :state => "NY",
    :population => 1586698,
    :airlines => [ "Delta", "JetBlue", "United" ]
  },
  {
    :name => "Brooklyn",
    :state => "NY",
    :population => 2504700,
    :airlines => [ "Delta", "American", "US Airways" ]
  },
  {
    :name => "Boston",
    :state => "MA",
    :population => 617594,
    :airlines => [ "Delta", "JetBlue", "American" ]
  },
  {
    :name => "Atlanta",
    :state => "GA",
    :population => 420003,
    :airlines => [ "Delta", "United", "SouthWest" ]
  },
  {
    :name => "Dallas",
    :state => "TX",
    :population => 1197816,
    :airlines => [ "Delta", "SouthWest", "Frontier" ]
  }
]
{% endhighlight %}

### Pivot cities by state for population over 750k {#pivot-cities-by-state-for-population-over-750k}

{% highlight ruby %}
# operation {#operation}
data = cities
  .pivot("state") { |city| city[:state] }
  .pivot("population >= 750k") { |city| city[:population] >= 750000 }

# resulting data {#resulting-data}
{
  { "state" => "CA", "population >= 750k" => true }  => [ { :name => "San Francisco", ... } ],
  { "state" => "CA", "population >= 750k" => false } => [ { :name => "Mountain View", ... } ],
  { "state" => "NY", "population >= 750k" => true }  => [ { :name => "Manhattan", ... }, { :name => "Brooklyn", ... } ],
  { "state" => "MA", "population >= 750k" => false } => [ { :name => "Boston", ... } ],
  { "state" => "GA", "population >= 750k" => false } => [ { :name => "Atlanta", ... } ],
  { "state" => "TX", "population >= 750k" => true }  => [ { :name => "Dallas", ... } ]
}
{% endhighlight %}

### Putting it all together {#putting-it-all-together}

**The end goal of all this is to support the creation of aggregate reports.**

*You can think of these reports as individual data cubes.*

Here is a table view of the pivoted city data from above.

<table>
  <thead>
    <tr>
      <th>state</th>
      <th>population >= 750k</th>
      <th>cities</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>CA</td>
      <td>true</td>
      <td>1</td>
    </tr>
    <tr>
      <td>CA</td>
      <td>false</td>
      <td>1</td>
    </tr>
    <tr>
      <td>NY</td>
      <td>true</td>
      <td>2</td>
    </tr>
    <tr>
      <td>MA</td>
      <td>false</td>
      <td>1</td>
    </tr>
    <tr>
      <td>GA</td>
      <td>false</td>
      <td>1</td>
    </tr>
    <tr>
      <td>TX</td>
      <td>true</td>
      <td>1</td>
    </tr>
  </tbody>
</table>

Lets try another one.

### Determine which airlines service cities with fewer than 750k people {#determine-which-airlines-service-cities-with-fewer-than-750k-people}

{% highlight ruby %}
# operation {#operation}
data = cities
  .pivot("airline") { |city| city[:airlines] }
  .pivot("population < 750k") { |city| city[:population] < 750000 }

# resulting data {#resulting-data}
{
  { "airline" => "Delta", "population < 750k" => false } => [
    { :name => "San Francisco", ... },
    { :name => "Manhattan", ... },
    { :name => "Brooklyn", ... },
    { :name => "Dallas", ... }],
  { "airline" => "Delta", "population < 750k" => true } => [
    { :name => "Boston", ... },
    { :name => "Atlanta", ... }],
  { "airline" => "United", "population < 750k" => false } => [
    { :name => "San Francisco", ... },
    { :name => "Manhattan", ... }],
  { "airline" => "United", "population < 750k" => true } => [
    { :name => "Mountain View", ... },
    { :name => "Atlanta", ... }],
  { "airline" => "SouthWest", "population < 750k" => false } => [
    { :name => "San Francisco", ... },
    { :name => "Dallas", ... }],
  { "airline" => "SouthWest", "population < 750k" => true } => [
    { :name => "Mountain View", ... },
    { :name => "Atlanta", ... }],
  { "airline" => "SkyWest", "population < 750k" => true } => [
    { :name => "Mountain View", ... }],
  { "airline" => "JetBlue", "population < 750k" => false } => [
    { :name => "Manhattan", ... }],
  { "airline" => "JetBlue", "population < 750k" => true } => [
    { :name => "Boston", ... }],
  { "airline" => "American", "population < 750k" => false } => [
    { :name => "Brooklyn", ... }],
  { "airline" => "American", "population < 750k" => true } => [
    { :name => "Boston", ... }],
  { "airline" => "US Airways", "population < 750k" => false } => [
    { :name => "Brooklyn", ... }],
  { "airline" => "Frontier", "population < 750k" => false } => [
    { :name => "Dallas", ... }]
}
{% endhighlight %}

Here is the corresponding table view for the above dataset.

<table>
  <thead>
    <tr>
      <th>airline</th>
      <th>population &lt; 750k</th>
      <th>cities</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Delta</td>
      <td>false</td>
      <td>4</td>
    </tr>
    <tr>
      <td>Delta</td>
      <td>true</td>
      <td>2</td>
    </tr>
    <tr>
      <td>United</td>
      <td>false</td>
      <td>2</td>
    </tr>
    <tr>
      <td>United</td>
      <td>true</td>
      <td>2</td>
    </tr>
    <tr>
      <td>SouthWest</td>
      <td>false</td>
      <td>2</td>
    </tr>
    <tr>
      <td>SouthWest</td>
      <td>true</td>
      <td>2</td>
    </tr>
    <tr>
      <td>SkyWest</td>
      <td>true</td>
      <td>1</td>
    </tr>
    <tr>
      <td>JetBlue</td>
      <td>false</td>
      <td>1</td>
    </tr>
    <tr>
      <td>JetBlue</td>
      <td>true</td>
      <td>1</td>
    </tr>
    <tr>
      <td>American</td>
      <td>false</td>
      <td>1</td>
    </tr>
    <tr>
      <td>American</td>
      <td>true</td>
      <td>1</td>
    </tr>
    <tr>
      <td>US Airways</td>
      <td>false</td>
      <td>1</td>
    </tr>
    <tr>
      <td>Frontier</td>
      <td>false</td>
      <td>1</td>
    </tr>
  </tbody>
</table>

Hopefully you can see the potential even though the above examples are somewhat contrived.

## Special thanks {#special-thanks}

* [One on One Marketing](http://www.1on1.com/) - for sponsoring the development of Goldmine
* [Eric Berry](https://github.com/cavneb/) - for constructive feedback
* [Brian Johnson](https://github.com/whap/) - for bringing some sanity to the recursion
* [Josh Bowles](https://github.com/jbowles/) - for early adoption and feedback
* [Brett Beers](https://github.com/beersbr/) - for early adoption and feedback
