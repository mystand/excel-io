# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'excel_io.rb'

Gem::Specification.new do |spec|
  spec.name          = "excel-io"
  spec.version       = ExcelIO::VERSION
  spec.date          = '2015-08-05'
  spec.authors       = ["Nikita Efanov"]
  spec.email         = ["info@mystand.ru", "utttt9111@gmail.com"]
  spec.summary       = "ExcelIO"
  spec.description   = "Gem for content management with Excel files"
  spec.homepage      = "http://rubygems.org/gems/excel-io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # spec.add_development_dependency "bundler", "~> 1.5"
  # spec.add_development_dependency "rake"
end