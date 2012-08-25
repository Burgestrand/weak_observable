describe WeakObservable do
  it "has a version" do
    defined?(WeakObservable::VERSION).should eq "constant"
  end

  describe "mixin" do
    let(:obj) do
      Object.new.tap { |o| o.extend WeakObservable::Mixin }
    end

    describe "#observers" do
      it "is a weak observable" do
        obj.observers.should be_a WeakObservable
      end

      it "is memoized" do
        obj.observers.should eql obj.observers
      end
    end
  end
end
