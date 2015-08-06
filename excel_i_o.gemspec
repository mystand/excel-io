$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "excel_i_o/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "excel_i_o"
  s.version     = ExcelIO::VERSION
  s.authors     = ["Nikita Efanov"]
  s.email       = ["info@mystand.ru", "utttt9111@gmail.com"]
  s.homepage    = "https://github.com/mystand/excel-io"
  s.summary     = "ExcelIO"
  s.description = "Gem for content management with Excel files"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", '~> 4.0', ">= 4.0.0"
end