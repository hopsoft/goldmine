$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "goldmine")
require "version"
require "miner"

module Goldmine
end

def Goldmine(list)
  Goldmine::Miner.new(list)
end
