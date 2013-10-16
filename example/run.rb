# An example of how to leverage the Goldmine Ruby GEM.
# Extracts specific info about WIFI hotspots in NY.
# Data source: https://nycopendata.socrata.com/data
#
# Generate the index.html page:
#
#   ruby /path/to/project/example/run.rb
#

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
# 3. define a presenter to help with rendering
# -----------------------------------------------------------------------------
class Presenter < Struct.new(:data, :mined_data)
  include ActiveSupport::NumberHelper

  def columns
    [:city, :free, :library, :hotspots, :percentage, :address_sum, :location_names, :zip_codes]
  end

  def city_header
    "City"
  end

  def city(record)
    record.first[:city]
  end

  def free_header
    "Free"
  end

  def free(record)
    return nil unless record.first[:free]
    "<span class='glyphicon glyphicon-star'></span>"
  end

  def library_header
    "Library"
  end

  def library(record)
    return nil unless record.first[:library]
    "<span class='glyphicon glyphicon-star'></span>"
  end

  def hotspots_header
    "Hotspots"
  end

  def hotspots(record)
    record.last.length
  end

  def percentage_header
    "Percentage"
  end

  def percentage(record)
    number_to_percentage (record.last.length / data.length.to_f) * 100, :precision => 2
  end

  def address_sum_header
    %Q{<span
      data-title="Computed Column"
      data-content="The sum of all address numbers in the set of matching records. Note: This is a contrived example illustrating the ability to compute column values."
      data-toggle="popover"
      data-placement="top">
      Address Sum
    </span>}
  end

  def address_sum(record)
    record.last.reduce(0) do |memo, row|
      memo + row["ADDRESS"].to_s.gsub(/\D/, "").to_i
    end
  end

  def location_names_header
    %Q{<span
      data-title="Computed Column"
      data-content="The total number of location names in the set of matching records. e.g. Starbucks, Barnes &amp; Noble, etc..."
      data-toggle="popover"
      data-placement="bottom">
      Location Names
    </span>}
  end

  def location_names(record)
    record.last.map { |row| row["NAME"].to_s.strip }.uniq.length
  end

  def zip_codes_header
    %Q{<span
      data-title="Computed Column"
      data-content="The total number of zip codes in the set of matching records."
      data-toggle="popover"
      data-placement="top">
      Zip Codes
    </span>}
  end

  def zip_codes(record)
    record.last.map { |row| row["ZIP"].to_s.strip }.uniq.length
  end

  def paid
    mined_data.select { |key, val| !key[:free] }
  end

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
  file.write Presenter.new(data, mined_data).render(template)
end

