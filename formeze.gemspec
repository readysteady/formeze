Gem::Specification.new do |s|
  s.name = 'formeze'
  s.version = '4.3.0'
  s.license = 'LGPL-3.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'https://github.com/readysteady/formeze'
  s.description = 'Ruby gem for validating form data'
  s.summary = 'See description'
  s.files = Dir.glob('lib/**/*.rb') + %w(CHANGES.md LICENSE.txt README.md formeze.gemspec)
  s.required_ruby_version = '>= 2.4.0'
  s.require_path = 'lib'
  s.metadata = {
    'homepage' => 'https://github.com/readysteady/formeze',
    'source_code_uri' => 'https://github.com/readysteady/formeze',
    'bug_tracker_uri' => 'https://github.com/readysteady/formeze/issues',
    'changelog_uri' => 'https://github.com/readysteady/formeze/blob/main/CHANGES.md'
  }
  s.add_dependency 'rack', '~> 3'
end
