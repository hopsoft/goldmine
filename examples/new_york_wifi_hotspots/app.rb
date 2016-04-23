require "sinatra"
require "csv"
require "json"
require "benchmark"
require File.expand_path("../../../lib/goldmine", __FILE__)

set :port, 3000

before do
  content_type "application/json"
end

get "/" do
  start = Time.now
  Benchmark.bm(15) do |x|
    x.report("raw")       { raw }
    x.report("pivoted")   { pivoted }
    x.report("rolled_up") { rolled_up }
    x.report("rows")      { rolled_up.to_rows }
    x.report("tabular")   { rolled_up.to_tabular }
    x.report("csv")       { rolled_up.to_tabular.to_csv }
  end

  JSON.dump(
    duration: Time.now - start,
    source_size: raw.size,
    rows: rolled_up.to_rows
  )
end

get "/raw" do
  JSON.dump(raw)
end

get "/pivoted" do
  JSON.dump(pivoted.to_h)
end

get "/rolled_up" do
  JSON.dump(rolled_up.to_h)
end

get "/rows" do
  JSON.dump(rolled_up.to_rows)
end

get "/hrows" do
  JSON.dump(rolled_up.to_hash_rows)
end

get "/tabular" do
  JSON.dump(rolled_up.to_tabular)
end

get "/csv" do
  content_type "text/csv"
  rolled_up.to_csv_table.to_s
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
  @pivoted ||= Goldmine(raw)
    .pivot("City")      { |row| row["CITY"] }
    .pivot("Zip Code")  { |row| row["ZIP"] }
    .pivot("Area Code") { |row| row["PHONE"].to_s.gsub(/\W/, "")[0, 3] }
    .result
end

def rolled_up
  @rolled_up ||= begin
    pivoted
      .rollup("Total", &:size)
      .rollup("Free")                 { |list| list.select { |row| !(row["TYPE"] =~ /free/i).nil? }.size }
      .rollup("Free Percentage")      { |list| cache["Free"] / cache["Total"].to_f }
      .rollup("Paid")                 { |list| list.select { |row| (row["TYPE"] =~ /free/i).nil? }.size }
      .rollup("Paid Percentage")      { |list| cache["Paid"] / cache["Total"].to_f }
      .rollup("Library")              { |list| list.select { |row| row["NAME"].to_s =~ /library/i }.size }
      .rollup("Library Percentage")   { |list| cache["Library"] / cache["Total"].to_f }
      .rollup("Starbucks")            { |list| list.select { |row| row["NAME"].to_s =~ /starbuck'?s/i }.size }
      .rollup("Starbucks Percentage") { |list| cache["Starbucks"] / cache["Total"].to_f }
      .rollup("McDonalds")            { |list| list.select { |row| row["NAME"].to_s =~ /McDonald'?s/i }.size }
      .rollup("McDonalds Percentage") { |list| cache["McDonalds"] / cache["Total"].to_f }
      .result(cache: true)
  end
end
