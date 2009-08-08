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
require 'couch_design_docs'

task :default => 'spec:run'

PROJ.name = 'couch_design_docs'
PROJ.authors = 'Chris Strom'
PROJ.email = 'chris@eeecooks.com'
PROJ.url = 'http://github.com/eee-c/couch_design_docs'
PROJ.version = CouchDesignDocs::VERSION
PROJ.rubyforge.name = 'couch_design_docs'

PROJ.spec.opts << '--color'

PROJ.gem.dependencies = %w{json rest-client}

depend_on 'rest-client'
depend_on 'json'

# EOF
