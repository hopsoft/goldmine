require File.expand_path("../lib/goldmine/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "goldmine"
  gem.license     = "MIT"
  gem.version     = Goldmine::VERSION
  gem.authors     = ["Nathan Hopkins"]
  gem.email       = ["natehop@gmail.com"]
  gem.homepage    = "https://github.com/hopsoft/goldmine"
  gem.summary     = "Extract a wealth of information from Arrays and Hashes"
  gem.description = "Extract a wealth of information from Arrays and Hashes"

  gem.files       = Dir["lib/**/*.rb", "bin/*", "[A-Z]*"]
  gem.test_files  = Dir["test/**/*.rb"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "pry-test"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "sinatra"
end

