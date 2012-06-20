require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'bundler'
Bundler.require :development, :test

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/test_*.rb']
end

task 'test:units' => ['test'] do
end
