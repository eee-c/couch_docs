require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CouchDocs do
  it "should be able to create (or delete/create) a DB" do
    Store.
      should_receive(:put!).
      with("couchdb_url", anything())

    CouchDocs.destructive_database_create("couchdb_url")
  end

  it "should be able to load design and normal documents" do
    CouchDocs.
      should_receive(:put_design_dir).
      with("uri", "fixtures/_design")

    CouchDocs.
      should_receive(:put_document_dir).
      with("uri", "fixtures")

    CouchDocs.put_dir("uri", "fixtures")
  end

  it "should be able to load directory/JS files into CouchDB as design docs" do
    store = mock("Store")
    Store.stub!(:new).and_return(store)

    dir = mock("Design Directory")
    dir.stub!(:to_hash).and_return({ "foo" => "bar" })
    DesignDirectory.stub!(:new).and_return(dir)

    store.
      should_receive(:put_design_documents).
      with({ "foo" => "bar" })

    CouchDocs.put_design_dir("uri", "fixtures")
  end

  it "should be able to load documents into CouchDB" do
    dir = mock("Document Directory")
    dir.
      stub!(:each_document).
      and_yield('foo', {"foo" => "1"})

    DocumentDirectory.stub!(:new).and_return(dir)

    Store.
      should_receive(:put!).
      with('uri/foo', {"foo" => "1"})

    CouchDocs.put_document_dir("uri", "fixtures")
  end

  it "should be able to upload a single document into CouchDB" do
    Store.
      should_receive(:put!).
      with('uri/foo', {"foo" => "1"})

    File.stub!(:read).and_return('{"foo": "1"}')

    CouchDocs.put_file("uri", "/foo")
  end

  context "dumping CouchDB documents to a directory" do
    before(:each) do
      @store = mock("Store")
      Store.stub!(:new).and_return(@store)

      @des_dir = mock("Design Directory").as_null_object
      DesignDirectory.stub!(:new).and_return(@des_dir)

      @dir = mock("Document Directory").as_null_object
      DocumentDirectory.stub!(:new).and_return(@dir)
    end
    it "should be able to store all CouchDB documents on the filesystem" do
      @store.stub!(:map).and_return([{'_id' => 'foo'}])
      @dir.
        should_receive(:store_document).
        with({'_id' => 'foo'})

      CouchDocs.dump("uri", "fixtures")
    end
    it "should ignore design documents" do
      @store.stub!(:map).and_return([{'_id' => '_design/foo'}])
      @dir.
        should_not_receive(:store_document)

      CouchDocs.dump("uri", "fixtures")
    end
    it "should strip revision numbers" do
      @store.stub!(:map).
        and_return([{'_id' => 'foo', '_rev' => '1-1234'}])
      @dir.
        should_receive(:store_document).
        with({'_id' => 'foo'})

      CouchDocs.dump("uri", "fixtures")
    end
    it "should not dump regular docs when asked for only design docs" do
      @store.stub!(:map).
        and_return([{'foo' => 'bar'}])

      @dir.
        should_not_receive(:store_document)

      CouchDocs.dump("uri", "fixtures", :design)
    end
    it "should not dump design docs when asked for only regular docs" do
      @store.stub!(:map).
        and_return([{'_id' => '_design/foo'}])

      @des_dir.
        should_not_receive(:store_document)

      CouchDocs.dump("uri", "fixtures", :doc)
    end
  end
end


describe Store do
  it "should require a CouchDB URL Root for instantiation" do
    lambda { Store.new }.
      should raise_error

    lambda { Store.new("uri") }.
      should_not raise_error
  end

  context "a valid store" do
    before(:each) do
      @it = Store.new("uri")

      @hash = {
        'a' => {
          'b' => {
            'c' => 'function(doc) { return true; }'
          }
        }
      }
    end

    it "should be able to put a new document" do
      Store.
        should_receive(:put).
        with("uri", { })

      Store.put!("uri", { })
    end

    it "should delete existing docs if first put fails" do
      Store.
        stub!(:put).
        and_raise(RestClient::RequestFailed)

      Store.
        should_receive(:delete_and_put).
        with("uri", { })

      Store.put!("uri", { })
    end

    it "should be able to delete and put" do
      Store.
        should_receive(:delete).
        with("uri")

      Store.
        should_receive(:put).
        with("uri", { })

      Store.delete_and_put("uri", { })
    end

    it "should be able to load a hash into design docs" do
      RestClient.
        should_receive(:put).
        with("uri/_design/a",
             '{"b":{"c":"function(doc) { return true; }"}}',
             :content_type => 'application/json')
      @it.put_design_documents(@hash)
    end

    it "should be able to retrieve an existing document" do
      RestClient.
        stub!(:get).
        and_return('{"_rev":"1234"}')

      Store.get("uri").should == { '_rev' => "1234" }
    end

    it "should be able to delete an existing document" do
      Store.stub!(:get).and_return({ '_rev' => '1234' })

      RestClient.
        should_receive(:delete).
        with("uri?rev=1234")

      Store.delete("uri")
    end

    it "should be able to load each document" do
      Store.stub!(:get).
        with("uri/_all_docs").
        and_return({ "total_rows" => 2,
                     "offset"     => 0,
                     "rows"       => [{"id"=>"1", "value"=>{}, "key"=>"1"},
                                      {"id"=>"2", "value"=>{}, "key"=>"2"}]})

      Store.stub!(:get).with("uri/1?attachments=true")
      Store.should_receive(:get).with("uri/2?attachments=true")

      @it.each { }
    end
  end
end

describe DocumentDirectory do
  it "should require a root directory for instantiation" do
    lambda { DocumentDirectory.new }.
      should raise_error

    lambda { DocumentDirectory.new("foo") }.
      should raise_error

    lambda { DocumentDirectory.new("fixtures")}.
      should_not raise_error
  end

  context "a valid directory" do
    before(:each) do
      @it = DocumentDirectory.new("fixtures")
    end

    it "should be able to iterate over the documents" do
      everything = []
      @it.each_document do |name, contents|
        everything << [name, contents]
      end

      everything.sort { |x,y| x[0] <=> y[0] }.
        should == [['bar', {"bar" => "2"}],
                   ['foo', {"foo" => "1"}]]
    end

    it "should be able to store a document" do
      file = mock("File", :write => 42, :close => true)
      File.
        should_receive(:new).
        with("fixtures/foo.json", "w+").
        and_return(file)

      @it.store_document({'_id' => 'foo'})
    end

    it "should be able to save a document as JSON" do
      file = mock("File", :close => true)
      File.stub!(:new).and_return(file)

      file.should_receive(:write).with(%Q|{"_id":"foo"}|)

      @it.store_document({'_id' => 'foo'})
    end
  end
end

describe DesignDirectory do
  it "should require a root directory for instantiation" do
    lambda { DesignDirectory.new }.
      should raise_error

    lambda { DesignDirectory.new("foo") }.
      should raise_error

    lambda { DesignDirectory.new("fixtures/_design")}.
      should_not raise_error
  end

  it "should convert arrays into deep hashes" do
    DesignDirectory.
      a_to_hash(%w{a b c d}).
      should == {
      'a' => {
        'b' => {
          'c' => 'd'
        }
      }
    }
  end

  context "a valid directory" do
    before(:each) do
      @it = DesignDirectory.new("fixtures/_design")
    end

    it "should list dirs, basename and contents of a js file" do
      @it.expand_file("fixtures/_design/a/b/c.js").
        should == ['a', 'b', 'c', 'function(doc) { return true; }']
    end

    it "should list dirs, basename and contents of a json file" do
      @it.expand_file("fixtures/_design/a/e.json").
        should == ['a', 'e', [{"one" => "2"}]]
    end

    it "should assemble all documents into a single docs structure" do
      @it.to_hash['a'].
        should == {
          'b' => {
            'c' => 'function(doc) { return true; }',
            'd' => 'function(doc) { return true; }'
          },
          'e' => [{"one" => "2"}]
        }
    end

    it "should process code macros when assembling" do
      @it.to_hash['x'].
        should == {
          'z' =>
           "// !begin code foo.js\n" +
           "function foo () { return \"foo\"; }\n" +
           "// !end code foo.js\n" +
           "function bar () { return \"bar\"; }\n"
      }
    end

    it "should ignore macro escape sequence when reading JSON" do
      @it.to_hash['j'].
        should == {'q' => ["!code foo.js"]}
    end

    it "should work with absolute !code paths"

    it "should replace !code macros with the contents of the referenced file in lib" do
      @it.stub!(:read_from_lib).and_return("awesome javascript")

      @it.
        process_code_macro(" // !code foo/bar.js ").
        should =~ /awesome javascript/
    end

    it "should not affect normal lines when processing macros" do
      @it.
        process_code_macro(" var foo = 'bar'; ").
        should == " var foo = 'bar'; "
    end

    it "should find files with relative paths in __lib" do
      File.
        should_receive(:read).
        with("fixtures/_design/__lib/foo.js")

      @it.read_from_lib("foo.js")
    end
  end

  # FIXME: json valued attributs get mangled when dumping design docs.
  context "saving a JSON attribute" do
  end

  context "saving a JS attribute" do
    before(:each) do
      @it = DesignDirectory.new("/tmp")

      FileUtils.stub!(:mkdir_p)
      @file = mock("File").as_null_object
      File.stub!(:new).and_return(@file)
    end

    it "should not store _id" do
      File.
        should_not_receive(:new).
        with("/tmp/_design/foo/_id.js", "w+")

      @it.save_js(nil, "_design/foo", { "_id" => "_design/foo"})
    end

    it "should create map the design document attribute to the filesystem" do
      FileUtils.
        should_receive(:mkdir_p).
        with("/tmp/_design/foo")

      @it.save_js("_design/foo", "bar", "json")
    end

    it "should store the attribute to the filesystem" do
      File.
        should_receive(:new).
        with("/tmp/_design/foo/bar.js", "w+")

      @it.save_js("_design/foo", "bar", "json")
    end

    it "should store hash values to the filesystem" do
      File.
        should_receive(:new).
        with("/tmp/_design/foo/bar/baz.js", "w+")

      @it.save_js("_design/foo", "bar", { "baz" => "json" })
    end

    it "should store the attribute to the filesystem" do
      @file.
        should_receive(:write).
        with("json")

      @it.save_js("_design/foo", "bar", "json")
    end

    it "should store the attributes with slashes to the filesystem" do
      File.
        should_receive(:new).
        with("/tmp/_design/foo/bar%2Fbaz.js", "w+")

      @it.save_js("_design/foo", "bar/baz", "json")
    end

    it "should strip lib code when dumping" do
      js = <<_JS
// !begin code foo.js
function foo () { return 'foo'; }
// !end code foo.js
// !begin code bar.js
function bar () { return 'bar'; }
// !end code bar.js
function baz () { return 'baz'; }
_JS

      @it.
        remove_code_macros(js).
        should == "// !code foo.js\n" +
                  "// !code bar.js\n" +
                  "function baz () { return 'baz'; }\n"
    end
  end
end

describe CommandLine do
  it "should be able to run a single instance of a command line" do
    CommandLine.
      should_receive(:new).
      with('foo', 'bar').
      and_return(mock("Command Line").as_null_object)

    CommandLine.run('foo', 'bar')
  end

  it "should run the command line instance" do
    command_line = mock("Command Line").as_null_object
    command_line.
      should_receive(:run)

    CommandLine.stub!(:new).and_return(command_line)

    CommandLine.run('foo', 'bar')
  end

  context "an instance that dumps a CouchDB database" do
    it "should dump CouchDB documents from uri to dir when run" do
      @it = CommandLine.new(['dump', 'uri', 'dir'])

      CouchDocs.
        should_receive(:dump).
        with("uri", "dir", nil)

      @it.run
    end

    it "should be able to dump only design documents" do
      @it = CommandLine.new(['dump', 'uri', 'dir', '-d'])

      CouchDocs.
        should_receive(:dump).
        with("uri", "dir", :design)

      @it.run
    end

    it "should be able to dump only regular documents" do
      @it = CommandLine.new(['dump', 'uri', 'dir', '-D'])

      CouchDocs.
        should_receive(:dump).
        with("uri", "dir", :doc)

      @it.run
    end

    it "should be an initial add if everything is an add" do
      @it = CommandLine.new(['push', 'uri'])
      args = [mock(:type => :added),
              mock(:type => :added)]
      @it.should be_initial_add(args)
    end

    it "should not be an initial add if something is not an add" do
      @it = CommandLine.new(['push', 'uri'])
      args = [mock(:type => :foo),
              mock(:type => :added)]
      @it.should_not be_initial_add(args)
    end

    it "should be a design docs update if something changes in _design" do
      @it = CommandLine.new(['push', 'uri'])
      args = [mock(:path => "foo"),
              mock(:path => "_design")]
      @it.should be_design_doc_update(args)
    end

    it "should know document updates" do
      @it = CommandLine.new(['push', 'uri'])
      doc_update = mock(:path => "foo")
      args = [doc_update,
              mock(:path => "_design")]

      @it.
        documents(args).
        should == [doc_update]
    end


    context "updates on the filesystem" do
      before(:each) do
        @args = mock("args")
        @it = CommandLine.new(%w(push uri dir))
      end
      it "should only update design docs if only local design docs have changed" do
        CouchDocs.
          should_receive(:put_dir)

        @it.stub!(:initial_add?).and_return(true)
        @it.directory_watcher_update(@args)
      end
      context "not an inital add" do
        before(:each) do
          @it.stub!(:initial_add?).and_return(false)
          @it.stub!(:design_doc_update?).and_return(false)
          @it.stub!(:documents).and_return([])
          CouchDocs.stub!(:put_design_dir)
        end
        it "should update design docs if there are design document updates" do
          CouchDocs.
            should_receive(:put_design_dir)

          @it.stub!(:design_doc_update?).and_return(true)
          @it.directory_watcher_update(@args)
        end
        it "should update documents (if any)" do
          file_mock = mock("File", :path => "/foo")
          @it.stub!(:documents).and_return([file_mock])

          CouchDocs.
            should_receive(:put_file).
            with("uri", "/foo")

          @it.directory_watcher_update(@args)
        end
      end
    end
  end

  context "pushing" do
    before(:each) do
      CouchDocs.stub!(:put_dir)

      @dw = mock("Directory Watcher").as_null_object
      DirectoryWatcher.stub!(:new).and_return(@dw)
    end

    it "should know watch" do
      @it = CommandLine.new(%w(push uri dir -w))
      @it.options[:watch].should be_true
    end

    it "should run once normally" do
      @dw.should_receive(:run_once)

      @it = CommandLine.new(%w(push uri dir))
      @it.run
    end

    it "should start a watcher with -w" do
      @dw.should_receive(:start)

      @it = CommandLine.new(%w(push uri dir -w))
      @it.stub!(:active?).and_return(false)
      @it.run
    end
  end

  context "an instance that uploads to a CouchDB database" do
    before(:each) do
      @it = CommandLine.new(['load', 'dir', 'uri'])
    end

    it "should load CouchDB documents from dir to uri when run" do
      CouchDocs.
        should_receive(:put_dir).
        with("uri", "dir")

      @it.run
    end
  end

end

# EOF
