Gem::Specification.new do |s|
  s.name = 'formeze'
  s.version = '3.0.0'
  s.license = 'LGPL-3.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'https://github.com/readysteady/formeze'
  s.description = 'A lightweight Ruby library for processing form data'
  s.summary = 'See description'
  s.files = Dir.glob('{lib,spec}/**/*') + %w(LICENSE.txt README.md Rakefile.rb formeze.gemspec)
  s.required_ruby_version = '>= 1.9.3'
  s.add_development_dependency('rake', '>= 12')
  s.add_development_dependency('i18n', '>= 0.9')
  s.add_development_dependency('minitest', '~> 5')
  s.add_development_dependency('mime-types', '~> 2')
  s.require_path = 'lib'
end
