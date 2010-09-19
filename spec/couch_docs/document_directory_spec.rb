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
        should include ['bar', {"bar" => "2"}]

      everything.
        should include ['foo', {"foo" => "1"}]
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

    context "pushing attachments to CouchDB" do
      before(:each) do
        @spacer_b64 = "R0lGODlhAQABAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgICAgMDAwP8AAAD/AP//AAAA//8A/wD//////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMwAAZgAAmQAAzAAA/wAzAAAzMwAzZgAzmQAzzAAz/wBmAABmMwBmZgBmmQBmzABm/wCZAACZMwCZZgCZmQCZzACZ/wDMAADMMwDMZgDMmQDMzADM/wD/AAD/MwD/ZgD/mQD/zAD//zMAADMAMzMAZjMAmTMAzDMA/zMzADMzMzMzZjMzmTMzzDMz/zNmADNmMzNmZjNmmTNmzDNm/zOZADOZMzOZZjOZmTOZzDOZ/zPMADPMMzPMZjPMmTPMzDPM/zP/ADP/MzP/ZjP/mTP/zDP//2YAAGYAM2YAZmYAmWYAzGYA/2YzAGYzM2YzZmYzmWYzzGYz/2ZmAGZmM2ZmZmZmmWZmzGZm/2aZAGaZM2aZZmaZmWaZzGaZ/2bMAGbMM2bMZmbMmWbMzGbM/2b/AGb/M2b/Zmb/mWb/zGb//5kAAJkAM5kAZpkAmZkAzJkA/5kzAJkzM5kzZpkzmZkzzJkz/5lmAJlmM5lmZplmmZlmzJlm/5mZAJmZM5mZZpmZmZmZzJmZ/5nMAJnMM5nMZpnMmZnMzJnM/5n/AJn/M5n/Zpn/mZn/zJn//8wAAMwAM8wAZswAmcwAzMwA/8wzAMwzM8wzZswzmcwzzMwz/8xmAMxmM8xmZsxmmcxmzMxm/8yZAMyZM8yZZsyZmcyZzMyZ/8zMAMzMM8zMZszMmczMzMzM/8z/AMz/M8z/Zsz/mcz/zMz///8AAP8AM/8AZv8Amf8AzP8A//8zAP8zM/8zZv8zmf8zzP8z//9mAP9mM/9mZv9mmf9mzP9m//+ZAP+ZM/+ZZv+Zmf+ZzP+Z///MAP/MM//MZv/Mmf/MzP/M////AP//M///Zv//mf//zP///yH5BAEAABAALAAAAAABAAEAAAgEALkFBAA7"
      end

      it "should connect attachments by sub-directory name (foo.json => foo/)" do
        @it.stub!(:mime_type)

        everything = []
        @it.each_document do |name, contents|
          everything << [name, contents]
        end

        everything.
          should include(['baz_with_attachments',
                         {'baz' => '3',
                            "_attachments" => { "spacer.gif" => {"data" => @spacer_b64} } }])
      end
      it "should mime 64 encode attachments" do
        # covered above
      end
      it "should ignore non-file attachments" do
        # covered above
      end

      context "infering mime type" do
        before(:each) do
          File.stub!(:read).and_return("asdf")
          Base64.stub!(:encode64).and_return("asdf")
        end

        it "should guess gif mime type" do
          @it.file_as_attachment("spacer.gif").
            should == {
            "data"         => "asdf",
            "content_type" => "image/gif"
          }
        end

        it "should guess jpeg mime type" do
          @it.file_as_attachment("spacer.jpg").
            should == {
            "data"         => "asdf",
            "content_type" => "image/jpeg"
          }
        end

        it "should guess png mime type" do
          @it.file_as_attachment("spacer.png").
            should == {
            "data"         => "asdf",
            "content_type" => "image/png"
          }
        end

        it "should default to no mime type" do
          @it.file_as_attachment("spacer.foo").
            should == {
            "data"         => "asdf"
          }
        end
      end

      it "should give precedence to filesystem attachments" do
        @it.stub!(:mime_type)

        JSON.stub!(:parse).
          and_return({ "baz" => "3",
                       "_attachments" => {
                         "spacer.gif" => "asdf",
                         "baz.jpg" => "asdf"
                       }
                     })

        everything = []
        @it.each_document do |name, contents|
          everything << [name, contents]
        end

        everything.
          should include(['baz_with_attachments',
                         {'baz' => '3',
                            "_attachments" => { "spacer.gif" => {"data" => @spacer_b64}, "baz.jpg" => "asdf" } }])
      end

    end
    context "dump attachments from CouchDB" do
      it "should create a sub-directory with document ID"
      it "should dump with native encoding (non-mime64)"
      it "should not include the attachments attribute"
    end
  end
end
