require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe CouchDocs::DocumentDirectory do
  it "should require a root directory for instantiation" do
    lambda { CouchDocs::DocumentDirectory.new }.
      should raise_error

    lambda { CouchDocs::DocumentDirectory.new("foo") }.
      should raise_error

    lambda { CouchDocs::DocumentDirectory.new("fixtures")}.
      should_not raise_error
  end

  context "a valid directory" do
    before(:each) do
      @it = CouchDocs::DocumentDirectory.new("fixtures")
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
