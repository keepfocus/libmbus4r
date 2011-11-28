# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "libmbus4r/version"

Gem::Specification.new do |s|
  s.name        = "libmbus4r"
  s.version     = Libmbus4r::VERSION
  s.authors     = ["Jakob Skov-Pedersen"]
  s.email       = ["jasp@keepfocus.dk"]
  s.homepage    = ""
  s.summary     = %q{Ruby adapter for libmbus library}
  s.description = %q{This allows ruby scripts to communicate with mbus enabled meters over a serial/ip adapter}

  s.rubyforge_project = "libmbus4r"

  s.extensions << 'ext/mbus/extconf.rb'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake-compiler"
  # s.add_runtime_dependency "rest-client"
end
