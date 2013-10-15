require File.join(File.expand_path("../lib", __FILE__), "goldmine", "version")

Gem::Specification.new do |gem|
  gem.name        = "goldmine"
  gem.license     = "MIT"
  gem.version     = Goldmine::VERSION
  gem.authors     = ["Nathan Hopkins"]
  gem.email       = ["natehop@gmail.com"]
  gem.homepage    = "https://github.com/hopsoft/goldmine"
  gem.summary     = "Pivot tables for the Rubyist."
  gem.description = "Pivot tables for the Rubyist."

  gem.files       = Dir["lib/**/*.rb", "bin/*", "[A-Z]*"]
  gem.test_files  = Dir["test/**/*.rb"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "micro_test"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "pry"
end
