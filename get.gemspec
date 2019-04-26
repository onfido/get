$:.push File.expand_path('../lib', __FILE__)
require 'get/version'

Gem::Specification.new do |s|
  s.name = 'get'
  s.version = Get::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Blake Turner']
  s.description = 'Encapsulate your database queries with dynamically generated classes'
  s.summary = 'Get is a library designed to encapsulate Rails database queries and prevent query pollution in the view layer.'
  s.email = 'mail@blakewilliamturner.com'
  s.homepage = 'https://github.com/BlakeTurner/get'
  s.license = 'MIT'

  s.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md)
  s.test_files    = Dir.glob("{spec}/**/*")
  s.require_paths = ['lib']

  s.add_runtime_dependency 'horza', '~> 1.0', '>= 1.0.3'

  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'activerecord', '>= 4.2'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'bundler-audit'
end
