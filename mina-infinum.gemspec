lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mina/infinum/version'

Gem::Specification.new do |spec|
  spec.name          = 'mina-infinum'
  spec.version       = Mina::Infinum::VERSION
  spec.authors       = ['Stjepan Hadjic']
  spec.email         = ['d4be4st@gmail.com']

  spec.summary       = 'Collection of mina plugins we use in infinum'
  spec.description   = 'Collection of mina plugins we use in infinum'
  spec.homepage      = 'https://github.com/infinum/mina-infinum'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'mina', '> 1.0'
  spec.add_dependency 'mina-data_sync'
  spec.add_dependency 'mina-dox'
  spec.add_dependency 'mina-secrets'
  spec.add_dependency 'mina-whenever'
end
