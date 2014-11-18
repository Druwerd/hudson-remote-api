# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hudson-remote-api/version"

Gem::Specification.new do |s|
  s.name        = "hudson-remote-api"
  s.version     = Hudson::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dru Ibarra"]
  s.email       = ["Druwerd@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Connect to Hudson's remote web API}
  s.description = %q{Connect to Hudson's remote web API}
  
  #s.add_development_dependency "rspec"

  s.rubyforge_project = "hudson-remote-api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
