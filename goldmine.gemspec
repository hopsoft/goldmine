require File.join(File.expand_path("../lib", __FILE__), "goldmine", "version")

Gem::Specification.new do |spec|
  spec.name        = "goldmine"
  spec.license     = "MIT"
  spec.version     = Goldmine::VERSION
  spec.authors     = ["Nathan Hopkins"]
  spec.email       = ["natehop@gmail.com"]
  spec.homepage    = "https://github.com/hopsoft/goldmine"
  spec.summary     = "Pivot tables for the Rubyist."
  spec.description = "Pivot tables for the Rubyist."

  spec.files       = Dir["lib/**/*.rb", "bin/*", "[A-Z]*"]
  spec.test_files  = Dir["test/**/*.rb"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "turn"
  spec.add_development_dependency "pry"
end
