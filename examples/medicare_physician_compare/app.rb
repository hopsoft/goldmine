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
  JSON.dump pivoted
end

get "/rolled_up" do
  JSON.dump rolled_up
end

get "/rows" do
  JSON.dump rolled_up.to_rows
end

get "/tabular" do
  JSON.dump rolled_up.to_tabular
end

get "/csv" do
  JSON.dump rolled_up.to_tabular
end

def raw
  @raw ||= begin
    [].tap do |rows|
      limit_per_page = 50_000
      (1..100_000).step(limit_per_page) do |offset|
        url = "https://data.medicare.gov/resource/aeay-dfax.json?$limit=#{limit_per_page}&$offset=#{offset - 1}"
        rows.concat JSON.parse(open(url).read)
      end
    end
  end
end

def pivoted
  @pivoted ||= begin
    Goldmine::ArrayMiner.new(raw)
      .pivot(:state) { |row| row["st"] }
      .pivot(:medical_specialty) { |row| row["pri_spec"] }
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
        computed(:preferred).for(list) / computed(:count).for(list).to_f
      }
      .rollup(:female) { |list|
        list.select { |row| row["gndr"] == "F" }.size
      }
      .rollup(:female_percent) { |list|
        computed(:female).for(list) / computed(:count).for(list).to_f
      }
      .rollup(:male) { |list|
        list.select { |row| row["gndr"] == "M" }.size
      }
      .rollup(:male_percent) { |list|
        computed(:male).for(list) / computed(:count).for(list).to_f
      }
      .rollup(:female_preferred) { |list|
        list.select { |row| row["gndr"] == "F" && row["assgn"] == "Y" && row["grd_yr"].to_i >= 2005 }.size
      }
      .rollup(:female_preferred_percent) { |list|
        preferred = computed(:preferred).for(list)
        if preferred > 0
          computed(:female_preferred).for(list) / computed(:preferred).for(list).to_f
        else
          0
        end
      }
      .rollup(:male_preferred) { |list|
        list.select { |row| row["gndr"] == "M" && row["assgn"] == "Y" && row["grd_yr"].to_i >= 2005 }.size
      }
      .rollup(:male_preferred_percent) { |list|
        preferred = computed(:preferred).for(list)
        if preferred > 0
          computed(:male_preferred).for(list) / computed(:preferred).for(list).to_f
        else
          0
        end
      }
  end
end
