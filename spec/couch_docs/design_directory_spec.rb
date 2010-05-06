require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe CouchDocs::DesignDirectory do
  it "should require a root directory for instantiation" do
    lambda { CouchDocs::DesignDirectory.new }.
      should raise_error

    lambda { CouchDocs::DesignDirectory.new("foo") }.
      should raise_error

    lambda { CouchDocs::DesignDirectory.new("fixtures/_design")}.
      should_not raise_error
  end

  it "should convert arrays into deep hashes" do
    CouchDocs::DesignDirectory.
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
      @it = CouchDocs::DesignDirectory.new("fixtures/_design")
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

  context "saving a JSON attribute" do
    it "should not mangle json valued attributes"
  end

  context "saving a JS attribute" do
    before(:each) do
      @it = CouchDocs::DesignDirectory.new("/tmp")

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
