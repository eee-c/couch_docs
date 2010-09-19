require 'base64'

module CouchDocs
  class DocumentDirectory

    attr_accessor :couch_doc_dir

    def initialize(path)
      Dir.new(path)
      @couch_doc_dir = path
    end

    def each_document
      Dir["#{couch_doc_dir}/*.json"].each do |filename|
        id = File.basename(filename, '.json')
        json = JSON.parse(File.new(filename).read)

        if File.directory? "#{couch_doc_dir}/#{id}"
          json["_attachments"] ||= { }
          Dir["#{couch_doc_dir}/#{id}/*"].each do |attachment|
            next unless File.file? attachment

            attachment_name = File.basename(attachment)
            type = mime_type(File.extname(attachment))
            data = File.read(attachment)
            json["_attachments"][attachment_name] =
              {
                "data" => Base64.encode64(data).gsub(/\n/, '')
              }
            if type
              json["_attachments"][attachment_name].
                merge!({"content_type" => type})
            end
          end
        end

        yield [ id, json ]
      end
    end

    def store_document(doc)
      file = File.new("#{couch_doc_dir}/#{doc['_id']}.json", "w+")
      file.write(doc.to_json)
      file.close
    end

    private
    def mime_type(extension)
      "image/gif"
    end
  end
end
