# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swagr/version'

Gem::Specification.new do |spec|
  spec.name          = 'swagr'
  spec.version       = Swagr::VERSION
  spec.authors       = ['Chris Parker']
  spec.email         = ['mrcsparker@gmail.com']

  spec.summary       = 'Ruby to Golang client for Swager API'
  spec.description   = 'This gem consumes a Swagger API json file and maps the API into Golang'
  spec.homepage      = 'https://github.com/mrcsparker/swagr'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.1'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
end
