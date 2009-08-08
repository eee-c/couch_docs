# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{couch_design_docs}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Strom"]
  s.date = %q{2009-07-31}
  s.default_executable = %q{couch_design_docs}
  s.description = %q{Manage CouchDB views and documents.}
  s.email = %q{chris@eeecooks.com}
  s.executables = ["couch_design_docs"]
  s.extra_rdoc_files = ["History.txt", "README.txt", "bin/couch_design_docs"]
  s.files = ["History.txt", "README.txt", "Rakefile", "bin/couch_design_docs", "couch_design_docs.gemspec", "fixtures/_design/a/b/c.js", "fixtures/_design/a/b/d.js", "fixtures/bar.json", "fixtures/foo.json", "lib/couch_design_docs.rb", "lib/couch_design_docs/design_directory.rb", "lib/couch_design_docs/document_directory.rb", "lib/couch_design_docs/store.rb", "spec/couch_design_docs_spec.rb", "spec/spec_helper.rb", "test/test_couch_design_docs.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/eee-c/couch_design_docs}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{couch_design_docs}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Manage CouchDB views and documents}
  s.test_files = ["test/test_couch_design_docs.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0.9.2"])
      s.add_runtime_dependency(%q<json>, [">= 1.1.3"])
      s.add_development_dependency(%q<bones>, [">= 2.5.1"])
    else
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0.9.2"])
      s.add_dependency(%q<json>, [">= 1.1.3"])
      s.add_dependency(%q<bones>, [">= 2.5.1"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0.9.2"])
    s.add_dependency(%q<json>, [">= 1.1.3"])
    s.add_dependency(%q<bones>, [">= 2.5.1"])
  end
end
