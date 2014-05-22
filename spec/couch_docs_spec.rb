require 'spec_helper'

describe CouchDocs do
  it "should be able to create (or delete/create) a DB" do
    CouchDocs::Store.
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
    CouchDocs::Store.stub!(:new).and_return(store)

    dir = mock("Design Directory")
    dir.stub!(:to_hash).and_return({ "foo" => "bar" })
    CouchDocs::DesignDirectory.stub!(:new).and_return(dir)

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

    CouchDocs::DocumentDirectory.stub!(:new).and_return(dir)

    CouchDocs::Store.
      should_receive(:put!).
      with('uri/foo', {"foo" => "1"})

    CouchDocs.put_document_dir("uri", "fixtures")
  end

  it "should be able to upload a single document into CouchDB" do
    CouchDocs::Store.
      should_receive(:put!).
      with('uri/foo', {"foo" => "1"})

    File.stub!(:read).and_return('{"foo": "1"}')

    CouchDocs.put_file("uri", "/foo")
  end

  context "dumping CouchDB documents to a directory" do
    before(:each) do
      @store = mock("Store")
      CouchDocs::Store.stub!(:new).and_return(@store)

      @des_dir = mock("Design Directory").as_null_object
      CouchDocs::DesignDirectory.stub!(:new).and_return(@des_dir)

      @dir = mock("Document Directory").as_null_object
      CouchDocs::DocumentDirectory.stub!(:new).and_return(@dir)
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

# EOF
