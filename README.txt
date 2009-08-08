couch_design_docs
    by Chris Strom
    http://github.com/eee-c/couch_design_docs

== DESCRIPTION:

Manage CouchDB views and documents.

== FEATURES/PROBLEMS:

* Store your CouchDB documents on the filesystem for on-demand
  upload.  Design documents are kept in a <tt>_design</tt>
  sub-directory, with <tt>.js</tt> extensions.  Normal documents are
  stored with a <tt>.json</tt> extension.

== SYNOPSIS:

  DB_URL = "http://localhost:5984/db"
  DIRECTORY = "/repos/db/couchdb/"

  # /repos/db/couchdb/_design/lucene/transform.js
  # /repos/db/couchdb/foo.json

  CouchDesignDocs.put_dir(DB_URL, DIRECTORY)

  # => lucene design document with a "transform" function containing
  #    the contents of transform.js
  #     - AND -
  #    a document named "foo" with the JSON contents from the foo.json
  #    file

== REQUIREMENTS:

* CouchDB
* JSON
* RestClient

== INSTALL:

* sudo gem install couch_design_docs

== LICENSE:

(The MIT License)

Copyright (c) 2009

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
