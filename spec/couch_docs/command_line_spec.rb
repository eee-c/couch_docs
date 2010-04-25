require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe CouchDocs::CommandLine do
  it "should be able to run a single instance of a command line" do
    CouchDocs::CommandLine.
      should_receive(:new).
      with('foo', 'bar').
      and_return(mock("Command Line").as_null_object)

    CouchDocs::CommandLine.run('foo', 'bar')
  end

  it "should run the command line instance" do
    command_line = mock("Command Line").as_null_object
    command_line.
      should_receive(:run)

    CouchDocs::CommandLine.stub!(:new).and_return(command_line)

    CouchDocs::CommandLine.run('foo', 'bar')
  end

  context "an instance that dumps a CouchDB database" do
    it "should dump CouchDB documents from uri to dir when run" do
      @it = CouchDocs::CommandLine.new(['dump', 'uri', 'dir'])

      CouchDocs.
        should_receive(:dump).
        with("uri", "dir", nil)

      @it.run
    end

    it "should be able to dump only design documents" do
      @it = CouchDocs::CommandLine.new(['dump', 'uri', 'dir', '-d'])

      CouchDocs.
        should_receive(:dump).
        with("uri", "dir", :design)

      @it.run
    end

    it "should be able to dump only regular documents" do
      @it = CouchDocs::CommandLine.new(['dump', 'uri', 'dir', '-D'])

      CouchDocs.
        should_receive(:dump).
        with("uri", "dir", :doc)

      @it.run
    end

    it "should be an initial add if everything is an add" do
      @it = CouchDocs::CommandLine.new(['push', 'uri'])
      args = [mock(:type => :added),
              mock(:type => :added)]
      @it.should be_initial_add(args)
    end

    it "should not be an initial add if something is not an add" do
      @it = CouchDocs::CommandLine.new(['push', 'uri'])
      args = [mock(:type => :foo),
              mock(:type => :added)]
      @it.should_not be_initial_add(args)
    end

    it "should be a design docs update if something changes in _design" do
      @it = CouchDocs::CommandLine.new(['push', 'uri'])
      args = [mock(:path => "foo"),
              mock(:path => "_design")]
      @it.should be_design_doc_update(args)
    end

    it "should know document updates" do
      @it = CouchDocs::CommandLine.new(['push', 'uri'])
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
        @it = CouchDocs::CommandLine.new(%w(push uri dir))
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
      @it = CouchDocs::CommandLine.new(%w(push uri dir -w))
      @it.options[:watch].should be_true
    end

    it "should run once normally" do
      @dw.should_receive(:run_once)

      @it = CouchDocs::CommandLine.new(%w(push uri dir))
      @it.run
    end

    it "should start a watcher with -w" do
      @dw.should_receive(:start)

      @it = CouchDocs::CommandLine.new(%w(push uri dir -w))
      @it.stub!(:active?).and_return(false)
      @it.run
    end
  end

  context "an instance that uploads to a CouchDB database" do
    before(:each) do
      @it = CouchDocs::CommandLine.new(['load', 'dir', 'uri'])
    end

    it "should load CouchDB documents from dir to uri when run" do
      CouchDocs.
        should_receive(:put_dir).
        with("uri", "dir")

      @it.run
    end
  end

end
