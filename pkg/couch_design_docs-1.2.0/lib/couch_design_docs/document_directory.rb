module CouchDesignDocs
  class DocumentDirectory

    attr_accessor :couch_doc_dir

    def initialize(path)
      Dir.new(path)
      @couch_doc_dir = path
    end

    def each_document
      Dir["#{couch_doc_dir}/*.json"].each do |filename|
        yield [ File.basename(filename, '.json'),
                JSON.parse(File.new(filename).read) ]

      end
    end

    def store_document(doc)
      file = File.new("#{couch_doc_dir}/#{doc['_id']}.json", "w+")
      file.write(doc.to_json)
      file.close
    end
  end
end
