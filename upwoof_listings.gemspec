lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upwoof_listings/version'

Gem::Specification.new do |spec|
  spec.name          = 'upwoof_listings'
  spec.version       = UpwoofListings::VERSION
  spec.authors       = ['David Iorns']
  spec.email         = ['david.iorns@gmail.com']
  spec.summary       = 'A Ruby wrapper for the UpWoof Listings API. https://www.upwoof_listings.org/api_v1'
  spec.homepage      = 'https://www.upwoof.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_dependency 'activesupport', '~> 8.0', '>= 8.0.2'
  spec.add_dependency 'faraday', '~> 2.13', '>= 2.13.1'
  spec.add_dependency 'faraday-multipart', '~> 1.1'
  spec.add_dependency 'mime-types', '~> 3.7'

  spec.add_development_dependency 'bundler', '~> 2.6', '>= 2.6.9'
  spec.add_development_dependency 'rake', '~> 13.3'
  spec.add_development_dependency 'rspec', '~> 3.13', '>= 3.13.1'
  spec.add_development_dependency 'vcr', '~> 6.3', '>= 6.3.1'
  spec.add_development_dependency 'webmock', '~> 3.25', '>= 3.25.1'
end
