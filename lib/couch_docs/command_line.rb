require 'optparse'
require 'pp'

module CouchDocs
  class CommandLine
    COMMANDS            = %w{push dump}
    DEPRECATED_COMMANDS = %w{load}

    def self.run(*args)
      CommandLine.new(*args).run
    end

    attr_reader :command, :options

    def initialize(args)
      parse_options(args)
    end

    def run
      case command
      when "dump"
        CouchDocs.dump(@options[:couchdb_url],
                       @options[:target_dir])
      when "push"
        if @options[:destructive]
          CouchDocs.destructive_database_create(options[:couchdb_url])
        end
        CouchDocs.put_dir(@options[:couchdb_url],
                          @options[:target_dir])
      when "load" # DEPRECATED
        CouchDocs.put_dir(@options[:target_dir],
                          @options[:couchdb_url])
      end
    end

    def parse_options(args)
      @options = { :target_dir => "." }

      options_parser = OptionParser.new do |opts|
        opts.banner = "Usage: couch-docs push|dump [OPTIONS] couchdb_url [target_dir]"

        opts.separator ""
        opts.separator "If a target_dir is not specified, the current working directory will be used."

        opts.separator ""
        opts.separator "Push options:"

        opts.on("-R", "--destructive",
                "Drop the couchdb_uri (if it exists) and create a new database") do
          @options[:destructive] = true
        end

        opts.on("-b", "--bulk [BATCH_SIZE=1000]", Integer,
                "Use bulk insert when pushing new documents") do |batch_size|
          @options[:bulk] = true
          @options[:batch_size] = batch_size || 1000
        end

        opts.separator ""
        opts.separator "Dump options:"

        opts.on("-d", "--design", "Only dump design documents") do
          @options[:design_docs_only] = true
        end
        opts.on("-D", "--data", "Only dump data documents") do
          @options[:data_docs_only] = true
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-v", "--version", "Show version") do
          puts File.basename($0) + " "  + CouchDocs::VERSION
          exit
        end

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end

      begin
        options_parser.parse!(args)
        additional_help = "#{options_parser.banner}\n\nTry --help for more options."
        unless (COMMANDS+DEPRECATED_COMMANDS).include? args.first
          puts "invalid command: \"#{args.first}\".  Must be one of #{COMMANDS.join(', ')}.\n\n"
          puts additional_help
          exit
        end
        @command = args.shift
        unless args.first
          puts "Missing required couchdb_uri argument.\n\n"
          puts additional_help
          exit
        end
        @options[:couchdb_url] = args.shift
        @options[:target_dir]  = args.shift if (args.size >= 1)

      rescue OptionParser::InvalidOption => e
        raise e
      end
    end
  end
end
