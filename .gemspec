require 'rake'

Gem::Specification.new do |spec|
  spec.name = 'one-pivot'
  spec.version = '0.9.3'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/one-on-one/pivot'
  spec.summary = 'Pivot provides basic pivoting functionality for sorting an Array of objects.'
  spec.description = <<-DESC
    Pivot provides basic pivoting functionality for sorting an Array of objects.
  DESC

  spec.authors = ['Nathan Hopkins']
  spec.email = ['natehop@gmail.com', 'natehop@1on1.com']

  #spec.add_dependency 'mash', '0.1.1'
  spec.add_development_dependency 'shoulda', '2.11.3'

  spec.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'test/**/*.rb'].to_a
end
