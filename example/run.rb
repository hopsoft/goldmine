# An example of how to leverage the Goldmine Ruby GEM.
# Extracts specific info about WIFI hotspots in NY.
# Data source: https://nycopendata.socrata.com/data

require "csv"
require "erb"
require "active_support/all"
require File.expand_path("../../lib/goldmine", __FILE__)

# -----------------------------------------------------------------------------
# 1. read the csv data into an array
# -----------------------------------------------------------------------------
data = []
file_path = File.expand_path("../DOITT_WIFI_HOTSPOT_01_13SEPT2010.csv", __FILE__)
CSV.foreach(file_path, :headers => true) do |row|
  data << row.to_hash
end

# -----------------------------------------------------------------------------
# 2. mine data out of the array
# -----------------------------------------------------------------------------
mined_data = Goldmine::ArrayMiner.new(data)

mined_data = mined_data.pivot(:city) do |row|
  row["CITY"]
end

mined_data = mined_data.pivot(:free) do |row|
  row["TYPE"] == "Free"
end

mined_data = mined_data.pivot(:library) do |row|
  row["NAME"].match(/library/i).present?
end

# -----------------------------------------------------------------------------
# 3. define a simple presenter for rendering
# -----------------------------------------------------------------------------
class Presenter < Struct.new(:mined_data)

  def free_libraries
    mined_data.select { |key, val| key[:free] && key[:library] }
  end

  def free_non_libraries
    mined_data.select { |key, val| key[:free] && !key[:library] }
  end

  def aggregate(key, records)
    records.map { |pair| [pair.first[key], pair.last.length] }
  end

  def render(template)
    ERB.new(template).result(binding)
  end

end

# -----------------------------------------------------------------------------
# 4. render an html based visualization of the data
# -----------------------------------------------------------------------------
file_path = File.expand_path("../index.html", __FILE__)
File.open(file_path, "w") do |file|
  template = File.read(File.expand_path("../index.html.erb", __FILE__))
  file.write Presenter.new(mined_data).render(template)
end

