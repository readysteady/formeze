Gem::Specification.new do |s|
  s.name = 'formeze'
  s.version = '2.1.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'http://github.com/timcraft/formeze'
  s.description = 'A little library for handling form data/input'
  s.summary = 'See description'
  s.files = Dir.glob('{lib,spec}/**/*') + %w(README.md Rakefile.rb formeze.gemspec)
  s.add_development_dependency('rake', ['>= 0.9.3'])
  s.add_development_dependency('i18n', ['~> 0.6.0'])
  s.add_development_dependency('minitest', ['>= 4.2.0']) if RUBY_VERSION == '1.8.7'
  s.require_path = 'lib'
end
