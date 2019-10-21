# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "couch_docs/version"

Gem::Specification.new do |s|
  s.name        = "couch_docs"
  s.version     = CouchDocs::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Strom"]
  s.email       = ["chris@eeecooks.com"]
  s.homepage    = "http://github.com/eee-c/couch_docs"
  s.summary     = %q{Manage CouchDB views and documents}
  s.description = %q{Manage CouchDB views and documents.}

  s.rubyforge_project = "couch_docs"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", ["~> 1.3.0"]

  s.add_runtime_dependency(%q<rest-client>, ">= 1.6", "< 2.2")
  s.add_runtime_dependency(%q<json>, ["~> 1.8.0"])
  s.add_runtime_dependency(%q<directory_watcher>, ["~> 1.3.0"])
  s.add_runtime_dependency(%q<mime-types>, ["~> 1.16"])
end
