require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "couch_docs"
    gemspec.summary = "Manage CouchDB views and documents."
    gemspec.description = "Provides a simple means for working with CouchDB documents on the filesystem.  It can dump CouchDB documents and design documents in discrete chunks.  Conversely it can read JSON and .js files from the filesystem to be pushed to a CouchDB database."
    gemspec.email = "eee.c@eeecooks.com"
    gemspec.homepage = "http://github.com/eee-c/couch_docs"
    gemspec.authors = ["Chris Strom"]
    gemspec.add_development_dependency "rspec", ">= 1.2.9"
    gemspec.add_dependency "rest-client", "1.1.0"
    gemspec.add_dependency "json", "1.2.0"
    gemspec.add_dependency "directory_watcher", "1.3.1"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "couch_docs #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
