require 'rake'

Gem::Specification.new do |spec|
  spec.name = 'one-pivot'
  spec.version = '0.9.4'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/one-on-one/pivot'
  spec.summary = 'Enumerable#group_by on steroids with an extra dash of awesome.'
  spec.description = <<-DESC
    A simple and intuitive way to perform powerful data mining on lists of objects.
    Think of it as MapReduce for mortals.
  DESC

  spec.authors = ['Nathan Hopkins']
  spec.email = ['natehop@gmail.com', 'natehop@1on1.com']

  spec.add_dependency 'eventmachine', '0.12.10'
  spec.add_development_dependency 'shoulda', '2.11.3'

  spec.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'test/**/*.rb'].to_a
end
