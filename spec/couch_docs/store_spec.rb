require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe CouchDocs::Store do
  it "should require a CouchDB URL Root for instantiation" do
    lambda { CouchDocs::Store.new }.
      should raise_error

    lambda { CouchDocs::Store.new("uri") }.
      should_not raise_error
  end

  context "a valid store" do
    before(:each) do
      @it = CouchDocs::Store.new("uri")

      @hash = {
        'a' => {
          'b' => {
            'c' => 'function(doc) { return true; }'
          }
        }
      }
    end

    it "should be able to put a new document" do
      CouchDocs::Store.
        should_receive(:put).
        with("uri", { })

      CouchDocs::Store.put!("uri", { })
    end

    it "should delete existing docs if first put fails" do
      CouchDocs::Store.
        stub!(:put).
        and_raise(RestClient::RequestFailed)

      CouchDocs::Store.
        should_receive(:delete_and_put).
        with("uri", { })

      CouchDocs::Store.put!("uri", { })
    end

    it "should be able to delete and put" do
      CouchDocs::Store.
        should_receive(:delete).
        with("uri")

      CouchDocs::Store.
        should_receive(:put).
        with("uri", { })

      CouchDocs::Store.delete_and_put("uri", { })
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

      CouchDocs::Store.get("uri").should == { '_rev' => "1234" }
    end

    it "should be able to delete an existing document" do
      CouchDocs::Store.stub!(:get).and_return({ '_rev' => '1234' })

      RestClient.
        should_receive(:delete).
        with("uri?rev=1234")

      CouchDocs::Store.delete("uri")
    end

    it "should be able to load each document" do
      CouchDocs::Store.stub!(:get).
        with("uri/_all_docs").
        and_return({ "total_rows" => 2,
                     "offset"     => 0,
                     "rows"       => [{"id"=>"1", "value"=>{}, "key"=>"1"},
                                      {"id"=>"2", "value"=>{}, "key"=>"2"}]})

      CouchDocs::Store.stub!(:get).with("uri/1?attachments=true")
      CouchDocs::Store.should_receive(:get).with("uri/2?attachments=true")

      @it.each { }
    end
  end
end
