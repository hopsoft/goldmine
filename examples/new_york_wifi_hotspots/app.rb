require "delegate"
require "sinatra"
require "csv"
require "json"
require "benchmark"
require File.expand_path("../../../lib/goldmine", __FILE__)

before do
  content_type "application/json"
end

get "/" do
  start = Time.now
  Benchmark.bm(15) do |x|
    x.report("raw") { raw }
    x.report("pivoted") { pivoted }
    x.report("computed") { computed }
    x.report("computed_tabular") { computed.to_tabular }
    x.report("computed_csv") { computed.to_tabular.to_csv }
  end

  JSON.dump(
    duration: Time.now - start,
    source_size: raw.size,
    computed_tabular: computed.to_tabular
  )
end

get "/raw" do
  JSON.dump(raw)
end

get "/pivoted" do
  JSON.dump(pivoted)
end

get "/computed" do
  JSON.dump(computed)
end

get "/computed_tabular" do
  JSON.dump(computed.to_tabular)
end

get "/computed_csv" do
  content_type "text/csv"
  computed.to_tabular.to_csv
end

private

def raw
  @raw ||= [].tap do |rows|
    file_path = File.expand_path("../DOITT_WIFI_HOTSPOT_01_13SEPT2010.csv", __FILE__)
    CSV.foreach(file_path, :headers => true) do |row|
      rows << row.to_hash
    end
  end
end

def pivoted
  @pivoted ||= Goldmine::ArrayMiner.new(raw)
    .pivot("City") { |row| row["CITY"] }
    .pivot("Zip Code") { |row| row["ZIP"] }
    .pivot("Area Code") { |row| row["PHONE"].to_s.gsub(/\W/, "")[0, 3] }
end

# NOTE: rollup blocks are called once for each pivot
#       best practice is to cache intermediate rollup results to avoid duplicate computations
#       this example omits caching for simplicity & clarity
def computed
  @computed ||= begin
    value = pivoted.rollup("Total") { |list| list.size }

    value = value.rollup("Free") do |list|
      list.select { |row| !(row["TYPE"] =~ /free/i).nil? }.size
    end

    value = value.rollup("Free Percentage") do |list|
      list.select { |row| !(row["TYPE"] =~ /free/i).nil? }.size / list.size.to_f
    end

    value = value.rollup("Paid") do |list|
      list.select { |row| (row["TYPE"] =~ /free/i).nil? }.size
    end

    value = value.rollup("Paid Percentage") do |list|
      list.select { |row| (row["TYPE"] =~ /free/i).nil? }.size / list.size.to_f
    end

    value = value.rollup("Library") do |list|
      list.select { |row| row["NAME"].to_s =~ /library/i }.size
    end

    value = value.rollup("Library Percentage") do |list|
      list.select { |row| row["NAME"].to_s =~ /library/i }.size / list.size.to_f
    end

    value = value.rollup("Starbucks") do |list|
      list.select { |row| row["NAME"].to_s =~ /starbuck'?s/i }.size
    end

    value = value.rollup("Starbucks Percentage") do |list|
      list.select { |row| row["NAME"].to_s =~ /starbuck'?s/i }.size / list.size.to_f
    end

    value = value.rollup("McDonalds") do |list|
      list.select { |row| row["NAME"].to_s =~ /McDonald'?s/i }.size
    end

    value = value.rollup("McDonalds Percentage") do |list|
      list.select { |row| row["NAME"].to_s =~ /McDonald'?s/i }.size / list.size.to_f
    end
  end
end

