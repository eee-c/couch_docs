module CouchDocs
  class CommandLine
    def self.run(*args)
      CommandLine.new(*args).run
    end

    attr_accessor :command, :options

    def initialize(args)
      @command = args.shift
      @options = args
    end

    def run
      case command
      when "dump"
        CouchDocs.dump(*options)
      when "load"
        CouchDocs.put_document_dir(*options.reverse)
      when "help", "--help", "-h"
        puts "#{$0} load dir         couchdb_uri"
        puts "#{$0} dump couchdb_uri dir"
      else
        raise ArgumentError.new("Unknown command #{command}")
      end
    end
  end
end
