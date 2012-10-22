Gem::Specification.new do |s|
  s.name = 'formeze'
  s.version = '1.5.1'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'http://github.com/timcraft/formeze'
  s.description = 'A little library for handling form data/input'
  s.summary = 'See description'
  s.files = Dir.glob('{lib,spec}/**/*') + %w(README.md Rakefile.rb formeze.gemspec)
  s.add_development_dependency('i18n', ['~> 0.6.0'])
  s.require_path = 'lib'
end
