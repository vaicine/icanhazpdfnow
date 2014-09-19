# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i_can_haz_pdf/version'

Gem::Specification.new do |spec|
  spec.name          = "icanhazpdf"
  spec.version       = ICanHazPdf::VERSION
  spec.authors       = ["Nic Pillinger"]
  spec.email         = ["nic@thelsf.co.uk"]
  spec.summary       = 'ICanHazPdf Client'
  spec.description   = 'Rails gem for generating and serving pdfs using ICanHazPdf service'
  spec.homepage      = "http://icanhazpdf.lsfapp.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec", "~> 4.3"
  spec.add_development_dependency "pry", "~> 0.10"

  spec.add_runtime_dependency 'activesupport', "~> 4.0"
  spec.add_runtime_dependency 'httparty', "~> 0.13"
end
