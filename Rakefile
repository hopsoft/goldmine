require "rake"
require "rake/testtask"
require "bundler/gem_tasks"

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.test_files = Dir["test/test_*.rb"]
end

