require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/fixtures/classes'

describe "Hash#[]" do
  it "returns the value for key" do
    obj = mock('x')
    h = { 1 => 2, 3 => 4, "foo" => "bar", obj => obj, [] => "baz" }
    h[1].should == 2
    h[3].should == 4
    h["foo"].should == "bar"
    h[obj].should == obj
    h[[]].should == "baz"
  end

  it "returns nil as default default value" do
    { 0 => 0 }[5].should == nil
  end

  it "returns the default (immediate) value for missing keys" do
    h = Hash.new(5)
    h[:a].should == 5
    h[:a] = 0
    h[:a].should == 0
    h[:b].should == 5
  end

  it "calls subclass implementations of default" do
    h = DefaultHash.new
    h[:nothing].should == 100
  end

  it "does not create copies of the immediate default value" do
    str = "foo"
    h = Hash.new(str)
    a = h[:a]
    b = h[:b]
    a << "bar"

    a.should equal(b)
    a.should == "foobar"
    b.should == "foobar"
  end

  it "returns the default (dynamic) value for missing keys" do
    h = Hash.new { |hsh, k| k.kind_of?(Numeric) ? hsh[k] = k + 2 : hsh[k] = k }
    h[1].should == 3
    h['this'].should == 'this'
    h.should == {1 => 3, 'this' => 'this'}

    i = 0
    h = Hash.new { |hsh, key| i += 1 }
    h[:foo].should == 1
    h[:foo].should == 2
    h[:bar].should == 3
  end

  it "does not return default values for keys with nil values" do
    h = Hash.new(5)
    h[:a] = nil
    h[:a].should == nil

    h = Hash.new() { 5 }
    h[:a] = nil
    h[:a].should == nil
  end

  it "compares keys with eql? semantics" do
    { 1.0 => "x" }[1].should == nil
    { 1.0 => "x" }[1.0].should == "x"
    { 1 => "x" }[1.0].should == nil
    { 1 => "x" }[1].should == "x"
  end

  it "compares key via hash" do
    # Can't use should_receive because it uses hash internally
    x = mock('0')
    def x.hash() 0 end

    { }[x].should == nil
  end

  it "does not compare key with unknown hash codes via eql?" do
    # Can't use should_receive because it uses hash and eql? internally
    x = mock('x')
    y = mock('y')
    def x.eql?(o) raise("Shouldn't receive eql?") end

    def x.hash() 0 end
    def y.hash() 1 end

    { y => 1 }[x].should == nil
  end

  it "compares key with found hash code via eql?" do
    # Can't use should_receive because it uses hash and eql? internally
    y = mock('0')
    def y.hash() 0 end

    x = mock('0')
    def x.hash()
      def self.eql?(o) taint; false; end
      return 0
    end

    { y => 1 }[x].should == nil
    x.tainted?.should == true

    x = mock('0')
    def x.hash()
      def self.eql?(o) taint; true; end
      return 0
    end

    { y => 1 }[x].should == 1
    x.tainted?.should == true
  end
end
