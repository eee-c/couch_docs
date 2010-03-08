class Hash
  def deep_merge(other)
    self.merge(other) do |key, oldval, newval|
      oldval.deep_merge(newval)
    end
  end
end

module CouchDocs
  class DesignDirectory

    attr_accessor :couch_view_dir

    def self.a_to_hash(a)
      key = a.first
      if (a.length > 2)
        { key => a_to_hash(a[1,a.length]) }
      else
        { key => a.last }
      end
    end

    def initialize(path)
      Dir.new(path) # Just checkin'
      @couch_view_dir = path
    end

    # Load

    def to_hash
      Dir["#{couch_view_dir}/**/*.js"].inject({}) do |memo, filename|
        DesignDirectory.
          a_to_hash(expand_file(filename)).
          deep_merge(memo)
      end
    end

    def expand_file(filename)
      File.dirname(filename).
        gsub(/#{couch_view_dir}\/?/, '').
        split(/\//) +
      [
       File.basename(filename, '.js').gsub(/%2F/, '/'),
       read_value(filename)
      ]
    end

    def read_value(filename)
      File.
        readlines(filename).
        map { |line| process_code_macro(line) }.
        join
    end

    def process_code_macro(line)
      if line =~ %r{\s*//\s*!code\s*(\S+)\s*}
        "// !begin code #{$1}\n" +
        read_from_lib($1) +
        "// !end code #{$1}\n"
      else
        line
      end
    end

    def read_from_lib(path)
      File.read("#{couch_view_dir}/__lib/#{path}")
    end

    # Store

    def store_document(doc)
      id = doc['_id']
      self.save_js(nil, id, doc)
    end

    def save_js(rel_path, key, value)
      if value.is_a? Hash
        value.each_pair do |k, v|
          next if k == '_id'
          self.save_js([rel_path, key].compact.join('/'), k, v)

        end
      else
        path = couch_view_dir + '/' + rel_path
        FileUtils.mkdir_p(path)

        file = File.new("#{path}/#{key.gsub(/\//, '%2F')}.js", "w+")
        file.write(remove_code_macros(value))
        file.close
      end
    end

    def remove_code_macros(js)
      js =~ %r{// !begin code ([.\w]+)$}m
      lib = $1
      if lib and js =~ %r{// !end code #{lib}$}m
        remove_code_macros(js.sub(%r{// !begin code #{lib}.+// !end code #{lib}}m, "// !code #{lib}"))
      else
        js
      end
    end
  end
end
