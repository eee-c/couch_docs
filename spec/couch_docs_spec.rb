require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CouchDocs do
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
    store = mock("Store")
    Store.stub!(:new).and_return(store)

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

  context "dumping CouchDB documents to a directory" do
    before(:each) do
      @store = mock("Store")
      Store.stub!(:new).and_return(@store)

      @dir = mock("Document Directory")
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
      everything.
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

    it "should list dirs, basename and contents of a file" do
      @it.expand_file("fixtures/_design/a/b/c.js").
        should == ['a', 'b', 'c', 'function(doc) { return true; }']
    end

    it "should assemble all documents into a single docs structure" do
      @it.to_hash.
        should == {
        'a' => {
          'b' => {
            'c' => 'function(doc) { return true; }',
            'd' => 'function(doc) { return true; }'
          }
        }

      }
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
    before(:each) do
      @it = CommandLine.new(['dump', 'uri', 'dir'])
    end

    it "should dump CouchDB documents from uri to dir when run" do
      CouchDocs.
        should_receive(:dump).
        with("uri", "dir")

      @it.run
    end
  end

  context "an instance that uploads to a CouchDB database" do
    before(:each) do
      @it = CommandLine.new(['load', 'dir', 'uri'])
    end

    it "should dump CouchDB documents from uri to dir when run" do
      CouchDocs.
        should_receive(:put_document_dir).
        with("uri", "dir")

      @it.run
    end
  end

end

# EOF
