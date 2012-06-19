require 'rake'

Gem::Specification.new do |spec|
  spec.name = 'goldmine'
  spec.version = '0.0.2'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/hopsoft/goldmine'
  spec.summary = 'Powerful data mining for lists of objects.'
  spec.description = <<-DESC
    ...
  DESC

  spec.authors = ['Nathan Hopkins']
  spec.email = ['natehop@gmail.com']

  spec.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'test/**/*.rb'].to_a
end
