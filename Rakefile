# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'couch_docs'

task :default => 'spec:run'

PROJ.name = 'couch_docs'
PROJ.authors = 'Chris Strom'
PROJ.email = 'chris@eeecooks.com'
PROJ.url = 'http://github.com/eee-c/couch_docs'
PROJ.version = CouchDocs::VERSION
PROJ.rubyforge.name = 'couch_docs'

PROJ.spec.opts << '--color'

#PROJ.gem.dependencies = %w{json rest-client}
PROJ.gem.development_dependencies << 'rspec'

PROJ.readme_file = 'README.rdoc'

depend_on 'rest-client', "~> 1.1.0"
depend_on 'json'
depend_on 'directory_watcher'

# EOF
