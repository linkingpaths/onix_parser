# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "onix_parser/version"

Gem::Specification.new do |s|
  s.name        = "onix_parser"
  s.version     = OnixParser::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Hill"]
  s.email       = ["david.esmale@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Parses ONIX 3.0 and 2.1 xml files}
  s.description = %q{Parses ONIX 3.0 and 2.1 xml files}

  s.rubyforge_project = "onix_parser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('hpricot', '~>0.8.4')

  s.add_development_dependency('rspec', '2.6.0')
  s.add_development_dependency('rspec-core', '2.6.3')
end
