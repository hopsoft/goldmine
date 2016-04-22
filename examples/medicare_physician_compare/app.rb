require "sinatra"
require "open-uri"
require "json"
require "benchmark"
require File.expand_path("../../../lib/goldmine", __FILE__)
require "pry"

set :port, 3000

before do
  content_type "application/json"
end

get "/" do
  start = Time.now
  raw
  source_data_duration = Time.now - start
  start = Time.now

  Benchmark.bm(15) do |x|
    x.report("pivoted") { pivoted }
    x.report("rolled_up") { rolled_up }
    x.report("rows") { rolled_up.to_rows }
    x.report("tabular") { rolled_up.to_tabular }
    x.report("csv") { rolled_up.to_tabular.to_csv }
  end

  JSON.dump(
    source_data_duration: source_data_duration,
    goldmine_duration: Time.now - start,
    source_size: raw.size,
    rows: rolled_up.to_rows
  )
end

get "/raw" do
  JSON.dump raw
end

get "/pivoted" do
  JSON.dump pivoted.to_h
end

get "/rolled_up" do
  JSON.dump rolled_up.to_h
end

get "/rows" do
  JSON.dump rolled_up.to_rows
end

get "/hrows" do
  JSON.dump(rolled_up.to_hash_rows)
end

get "/tabular" do
  JSON.dump rolled_up.to_tabular
end

get "/csv" do
  content_type "text/csv"
  rolled_up.to_csv_table.to_s
end

def raw
  @raw ||= begin
    [].tap do |rows|
      limit_per_page = 50_000
      (1..1_000_000).step(limit_per_page) do |offset|
        url = "https://data.medicare.gov/resource/aeay-dfax.json?$limit=#{limit_per_page}&$offset=#{offset - 1}"
        rows.concat JSON.parse(open(url).read)
      end
    end
  end
end

def pivoted
  @pivoted ||= begin
    Goldmine::Miner.new(raw)
      .pivot(:state)             { |row| row["st"] }
      .pivot(:medical_specialty) { |row| row["pri_spec"] }
      .result
  end
end

def rolled_up
  @rolled_up ||= begin
    pivoted
      .rollup(:count, &:size)
      .rollup(:preferred) { |list|
        list.select { |row| row["assgn"] == "Y" && row["grd_yr"].to_i >= 2005 }.size
      }
      .rollup(:preferred_percent) { |list|
        cache.read(:preferred, list) / cache.read(:count, list).to_f
      }
      .rollup(:female) { |list|
        list.select { |row| row["gndr"] == "F" }.size
      }
      .rollup(:female_percent) { |list|
        cache.read(:female, list) / cache.read(:count, list).to_f
      }
      .rollup(:male) { |list|
        list.select { |row| row["gndr"] == "M" }.size
      }
      .rollup(:male_percent) { |list|
        cache.read(:male, list) / cache.read(:count, list).to_f
      }
      .rollup(:female_preferred) { |list|
        list.select { |row| row["gndr"] == "F" && row["assgn"] == "Y" && row["grd_yr"].to_i >= 2005 }.size
      }
      .rollup(:female_preferred_percent) { |list|
        preferred = cache.read(:preferred, list)
        if preferred > 0
          cache.read(:female_preferred, list) / cache.read(:preferred, list).to_f
        else
          0
        end
      }
      .rollup(:male_preferred) { |list|
        list.select { |row| row["gndr"] == "M" && row["assgn"] == "Y" && row["grd_yr"].to_i >= 2005 }.size
      }
      .rollup(:male_preferred_percent) { |list|
        preferred = cache.read(:preferred, list)
        if preferred > 0
          cache.read(:male_preferred, list) / cache.read(:preferred, list).to_f
        else
          0
        end
      }
      .result(cache: true)
  end
end
