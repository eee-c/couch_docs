# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{couch_docs}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Strom"]
  s.date = %q{2010-03-11}
  s.default_executable = %q{couch-docs}
  s.description = %q{Manage CouchDB views and documents.}
  s.email = %q{chris@eeecooks.com}
  s.executables = ["couch-docs"]
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "bin/couch-docs"]
  s.files = ["History.txt", "README.rdoc", "Rakefile", "bin/couch-docs", "couch_docs.gemspec", "fixtures/_design/__lib/foo.js", "fixtures/_design/a/b/c.js", "fixtures/_design/a/b/d.js", "fixtures/_design/x/z.js", "fixtures/bar.json", "fixtures/foo.json", "lib/couch_docs.rb", "lib/couch_docs/command_line.rb", "lib/couch_docs/design_directory.rb", "lib/couch_docs/document_directory.rb", "lib/couch_docs/store.rb", "spec/couch_docs_spec.rb", "spec/spec_helper.rb", "test/test_couch_docs.rb"]
  s.homepage = %q{http://github.com/eee-c/couch_docs}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{couch_docs}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Manage CouchDB views and documents}
  s.test_files = ["test/test_couch_docs.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.1.0"])
      s.add_runtime_dependency(%q<json>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<directory_watcher>, [">= 1.3.1"])
      s.add_development_dependency(%q<bones>, [">= 2.5.0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, ["~> 1.1.0"])
      s.add_dependency(%q<json>, [">= 1.2.0"])
      s.add_dependency(%q<directory_watcher>, [">= 1.3.1"])
      s.add_dependency(%q<bones>, [">= 2.5.0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, ["~> 1.1.0"])
    s.add_dependency(%q<json>, [">= 1.2.0"])
    s.add_dependency(%q<directory_watcher>, [">= 1.3.1"])
    s.add_dependency(%q<bones>, [">= 2.5.0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
