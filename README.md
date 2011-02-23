#[1on1](http://1on1.com/) one-pivot GEM

##Overview
The **one-pivot** GEM provides a simple way to mine data from a list of objects. There are no constraints on the types of objects that you can pivot. You can pivot anything from a list of numbers to a list of ActiveRecord objects to anything in between.  

**`One::Pivoter`** exposes two methods of importance.  

* **`pivot`** - runs a single pivot 
* **`multi-pivot`** - stacks multiple pivots into a single result

A **`pivot`** is simply a Ruby block (or Proc) that executes for each item in the list.  The result returned from this block then serves as the key in the resulting Hash.

Lets have a look at some examples.

_Note: there are a few advanced features not demonstrated in the examples below. For example, adding identifiers to pivots or attaching observers to pivot operations. We use these features at 1on1 to cache pivot results for each item. This gives us a big performance boost when the same item participates in multiple pivots during its lifetime... especially when the pivot Proc is an expensive operation.  Have a look at the [tests](https://github.com/one-on-one/pivot/tree/master/test) when you want to dig a little deeper._

##Installation
<pre>
<code>
gem install one-pivot
</code>
</pre>

##A simple single pivot
<pre>
<code>
require 'one-pivot'

# create the pivot instance
pivoter = One::Pivoter.new

# create a list of objects to pivot
list = [1,2,3,4,5,6,7,8,9]

# run a single pivot
# note: the block passed to the pivot method is invoked for each item in the list
# note: the result from the block will act as the 'key' in the resulting Hash
result = pivoter.pivot(list) {|item| item <= 5}

# 'result' will be a Hash with the following structure
{
  true => [1,2,3,4,5],
  false => [6,7,8,9]
}
</code>
</pre>


##A simple multi-pivot
<pre>
<code>
require 'one-pivot'

# create the pivot instance
# note: the multi-pivot delimiter that was specified
pivoter = One::Pivoter.new

# create a list of objects to pivot
list = [1,2,3,4,5,6,7,8,9]

# run several pivots together
pivots = []

pivots << lambda do |i|
  key = "less than or equal to 5" if i <= 5
  key ||= "greater than 5"
end

pivots << lambda do |i|
  key = "greater than or equal to 3" if i >= 3
  key ||= "less than 3"
end

pivots << {:delimiter => " & "}

result = pivoter.multi_pivot(list, *pivots)

# 'result' will be a Hash with the following structure
{
  "less than or equal to 5 & greater than or equal to 3" => [3, 4, 5], 
  "less than or equal to 5 & less than 3" => [1, 2], 
  "greater than 5 & greater than or equal to 3" => [6, 7, 8, 9]
}
</code>
</pre>

##A real world example
<pre>
<code>
# we'll be working with ActiveRecord objects based on the following schema
# ============================================================================
# create_table "users", :force => true do |t|
#   t.string   "name"
#   t.datetime "created_at"
#   t.datetime "updated_at"
# end
#
# create_table "skills", :force => true do |t|
#   t.string   "name"
#   t.datetime "created_at"
#   t.datetime "updated_at"
# end
#
# create_table "skills_users", :id => false, :force => true do |t|
#   t.integer "user_id"
#   t.integer "skill_id"
# end
# 
# and will seed the datbase with the following data
# ============================================================================
# ruby = Skill.create(:name => "Ruby")
# python = Skill.create(:name => "Python")
# php = Skill.create(:name => "PHP")
# javascript = Skill.create(:name => "JavaScript")
# 
# users = User.create([
#   {:name => "Ryan", :skills => [ruby]},
#   {:name => "Dave", :skills => [php, javascript]},
#   {:name => "Brett", :skills => [ruby, javascript]},
#   {:name => "Jay", :skills => [ruby, python, php, javascript]},
#   {:name => "Doug"}
# ])
#

require 'one-pivot'

pivoter = One::Pivoter.new
# note that the pivot block returns an array
# each unique value in the arrays returned will become a key in the resulting Hash
result = pivoter.pivot(User.all) do |user|
  user.skills
end

# 'result' will be Hash with the following structure
# note: I've simplified the object structure (using names only) for clarity 
{
  "Ruby" => ["Brett", "Jay", "Ryan"],
  "PHP" => ["Dave", "Jay"],
  "JavaScript" => ["Brett", "Dave", "Jay"],
  "Python" => ["Jay"],
  nil => ["Doug"]
} 
</code>
</pre>
