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
            json["_attachments"][attachment_name] = file_as_attachment(attachment)
          end
        end

        yield [ id, json ]
      end
    end

    def store_document(doc)
      file = File.new("#{couch_doc_dir}/#{doc['_id']}.json", "w+")
      store_attachments(doc['_id'], doc.delete('_attachments'))
      file.write(doc.to_json)
      file.close
    end

    def file_as_attachment(file)
      type = mime_type(File.extname(file))
      data = File.read(file)

      attachment =  {
        "data" => Base64.encode64(data).gsub(/\n/, '')
      }
      if type
        attachment.merge!({"content_type" => type})
      end

      attachment
    end

    def store_attachments(id, attachments)
      return unless attachments

      make_attachment_dir(id)
      attachments.each do |filename, opts|
        save_attachment(id, filename, opts['data'])
      end
    end

    def make_attachment_dir(id)
      FileUtils.mkdir_p "#{couch_doc_dir}/#{id}"
    end

    def save_attachment(id, filename, data)
      file = File.new "#{couch_doc_dir}/#{id}/#{filename}", "w"
      file.write Base64.decode64(data)
      file.close
    end

    private
    def mime_type(extension)
      ({
         ".gif" => "image/gif",
         ".jpg" => "image/jpeg",
         ".png" => "image/png"
       })[extension]
    end
  end
end
