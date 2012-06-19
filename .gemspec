require 'rake'

Gem::Specification.new do |spec|
  spec.name = 'goldmine'
  spec.version = '0.0.3'
  spec.license = 'MIT'
  spec.homepage = 'http://hopsoft.github.com/goldmine/'
  spec.summary = 'Data mining made easy... the Ruby way.'
  spec.description = <<-DESC
    Goldmine allows you to apply pivot table logic to any list for powerful data mining capabilities.
  DESC

  spec.authors = ['Nathan Hopkins']
  spec.email = ['natehop@gmail.com']

  spec.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'test/**/*.rb'].to_a
end
