$:.push File.expand_path('../lib', __FILE__)
require 'orm_adapter/version'

Gem::Specification.new do |s|
  s.name = 'get'
  s.version = OrmAdapter::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.authors = ['Blake Turner']
  s.description = 'Encapsulate your database queries with dynamically generated classes'
  s.summary = 'Get is a library designed to encapsulate Rails database queries and prevent query pollution in the view layer.'
  s.email = 'mail@blakewilliamturner.com'
  s.homepage = 'https://github.com/BlakeTurner/get'
  s.license = 'MIT'

  s.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md)
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split('\n')
  s.require_paths = ['lib']

  s.add_runtime_dependency 'hashie', '3.4.1'

  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'git', '>= 1.2.5'
  s.add_development_dependency 'yard', '>= 0.6.0'
  s.add_development_dependency 'rake', '>= 0.8.7'
  s.add_development_dependency 'activerecord', '>= 3.2.15'
  s.add_development_dependency 'activesupport', '>= 3.2.15'
  s.add_development_dependency 'rspec', '>= 2.4.0'
  s.add_development_dependency 'dm-sqlite-adapter', '>= 1.0'
  s.add_development_dependency 'dm-active_model', '>= 1.0'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'sqlite3'
end
