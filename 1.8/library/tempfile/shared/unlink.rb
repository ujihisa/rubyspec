shared :tempfile_unlink do |cmd|
  describe "Tempfile##{cmd}" do
    before(:each) do
      @tempfile = Tempfile.new("specs")
    end
    
    after(:each) do
      @tempfile.close
    end
    
    it "unlinks self" do
      File.should_receive(:unlink).with(@tempfile.path)
      @tempfile.send(cmd)
    end
  end
end