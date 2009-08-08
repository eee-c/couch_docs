module CouchDesignDocs

  # :stopdoc:
  VERSION = '1.2.0'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # For a CouchDB database described by <tt>db_uri</tt> and a
  # directory, <tt>dir</tt> containing design documents, creates
  # design documents in the CouchDB database
  #
  def self.put_dir(db_uri, dir)
    self.put_design_dir(db_uri, "#{dir}/_design")
    self.put_document_dir(db_uri, dir)
  end

  # Alias for <tt>put_dir</tt>
  def self.upload_dir(db_uri, dir)
    self.put_dir(db_uri, dir)
  end

  # Upload design documents from <tt>dir</tt> to the CouchDB database
  # located at <tt>db_uri</tt>
  #
  def self.put_design_dir(db_uri, dir)
    store = Store.new(db_uri)
    dir = DesignDirectory.new(dir)
    store.put_design_documents(dir.to_hash)
  end

  # Upload documents from <tt>dir</tt> to the CouchDB database
  # located at <tt>db_uri</tt>
  #
  def self.put_document_dir(db_uri, dir)
    store = Store.new(db_uri)
    dir = DocumentDirectory.new(dir)
    dir.each_document do |name, contents|
      Store.put!("#{db_uri}/#{name}", contents)
    end
  end

  # Dump all documents located at <tt>db_uri</tt> into the directory
  # <tt>dir</tt>
  #
  def self.dump(db_uri, dir)
    store = Store.new(db_uri)
    dir = DocumentDirectory.new(dir)
    store.
      map.
      reject { |doc| doc['_id'] =~ /^_design/ }.
      each   { |doc| dir.store_document(doc) }
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

end  # module CouchDesignDocs

CouchDesignDocs.require_all_libs_relative_to(__FILE__)

# EOF
