Gem::Specification.new do |s|
  s.name = 'formeze'
  s.version = '1.2.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'http://github.com/timcraft/formeze'
  s.description = 'A little library for handling form data/input'
  s.summary = 'See description'
  s.files = Dir.glob('{lib,spec}/**/*') + %w(README.md Rakefile.rb formeze.gemspec)
  s.require_path = 'lib'
end
