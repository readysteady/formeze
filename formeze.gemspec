Gem::Specification.new do |s|
  s.name = 'formeze'
  s.version = '3.0.0'
  s.license = 'LGPL-3.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'http://github.com/timcraft/formeze'
  s.description = 'A little Ruby library for handling form data/input'
  s.summary = 'See description'
  s.files = Dir.glob('{lib,spec}/**/*') + %w(LICENSE.txt README.md Rakefile.rb formeze.gemspec)
  s.required_ruby_version = '>= 1.9.3'
  s.add_development_dependency('rake', '~> 10')
  s.add_development_dependency('i18n', '~> 0.6')
  s.add_development_dependency('minitest', '~> 5')
  s.add_development_dependency('mime-types', '~> 2')
  s.require_path = 'lib'
end
