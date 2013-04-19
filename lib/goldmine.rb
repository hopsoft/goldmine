$:.unshift File.join(File.dirname(__FILE__), "goldmine")
require "array_miner"
require "hash_miner"

::Array.send(:include, Goldmine::ArrayMiner)
::Hash.send(:include, Goldmine::HashMiner)
