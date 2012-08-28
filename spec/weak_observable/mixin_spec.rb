describe WeakObservable::Mixin do
  let(:klass) { Class.new { include WeakObservable::Mixin } }
  let(:observable) { klass.new }

  describe "#observers" do
    it "is a weak observable" do
      observable.observers.should be_a WeakObservable
    end

    it "is memoized" do
      observable.observers.should eql observable.observers
    end
  end
end
