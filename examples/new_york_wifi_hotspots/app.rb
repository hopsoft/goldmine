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
    x.report("raw") { raw }
    x.report("pivoted") { pivoted }
    x.report("rolled_up") { rolled_up }
    x.report("rows") { rolled_up.to_rows }
    x.report("tabular") { rolled_up.to_tabular }
    x.report("csv") { rolled_up.to_tabular.to_csv }
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
  JSON.dump(pivoted)
end

get "/rolled_up" do
  JSON.dump(rolled_up)
end

get "/rows" do
  JSON.dump(rolled_up.to_rows)
end

get "/tabular" do
  JSON.dump(rolled_up.to_tabular)
end

get "/csv" do
  content_type "text/csv"
  rolled_up.to_tabular.to_csv
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

def rolled_up
  @rolled_up ||= begin
    pivoted
      .rollup("Total") { |list| list.size }
      .rollup("Free") { |list|
        list.select { |row| !(row["TYPE"] =~ /free/i).nil? }.size
      }
      .rollup("Free Percentage") { |list|
        computed("Free").for(list) / computed("Total").for(list).to_f
      }
      .rollup("Paid") { |list|
        list.select { |row| (row["TYPE"] =~ /free/i).nil? }.size
      }
      .rollup("Paid Percentage") { |list|
        computed("Paid").for(list) / computed("Total").for(list).to_f
      }
      .rollup("Library") { |list|
        list.select { |row| row["NAME"].to_s =~ /library/i }.size
      }
      .rollup("Library Percentage") { |list|
        computed("Library").for(list) / computed("Total").for(list).to_f
      }
      .rollup("Starbucks") { |list|
        list.select { |row| row["NAME"].to_s =~ /starbuck'?s/i }.size
      }
      .rollup("Starbucks Percentage") { |list|
        computed("Starbucks").for(list) / computed("Total").for(list).to_f
      }
      .rollup("McDonalds") { |list|
        list.select { |row| row["NAME"].to_s =~ /McDonald'?s/i }.size
      }
      .rollup("McDonalds Percentage") { |list|
        computed("McDonalds").for(list) / computed("Total").for(list).to_f
      }
  end
end
