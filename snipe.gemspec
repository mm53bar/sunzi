# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "snipe/version"

Gem::Specification.new do |s|
  s.name        = "snipe"
  s.version     = Snipe::VERSION
  s.authors     = ["Mike McClenaghan"]
  s.email       = ["mike@sideline.ca"]
  s.homepage    = "http://github.com/mm53bar/snipe"
  s.summary     = %q{Building boxes with no crap}
  s.description = %q{Building boxes with no crap}

  s.rubyforge_project = "snipe"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "rainbow"
  s.add_development_dependency "rake"
end
