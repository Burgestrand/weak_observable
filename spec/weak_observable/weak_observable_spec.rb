describe WeakObservable do
  let(:observable) { WeakObservable.new }
  let(:observer) { stub(:update => nil) }

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

  describe "#add and #notify" do
    it "adds an observer" do
      observer.should_receive(:update)

      observable.add(observer)
      observable.notify
    end

    it "allows us to specify callback method" do
      observer.should_receive(:trigger)

      observable.add(observer, :trigger)
      observable.notify
    end
  end

  describe "#notify" do
    it "passes along the given block" do
      observer.should_receive(:update).and_return do |&block|
        block.call(2)
      end

      observable.add(observer)
      observable.notify { |x| x * 2 }.should eq [4]
    end

    it "returns all return values" do
      observer1 = stub(:update => 1)
      observer2 = stub(:update => 2)

      observable.add(observer1)
      observable.add(observer2)

      observable.notify.should eq [1, 2]
    end
  end

  describe "#delete" do
    it "removes the observer" do
      observer.should_not_receive(:update)

      observable.add(observer)
      observable.delete(observer)
      observable.notify.should eq []
    end
  end

  specify "observers can be garbage collected" do
    counter   = 0
    finalizer = lambda { |_| counter += 1 }

    threshold = 5
    stretches = 5

    threshold.times do
      observer = stub(:update)
      observable.add(observer)
      ObjectSpace.define_finalizer(observer, finalizer)
    end

    (threshold * stretches).times do
      GC.start
      sleep 0.001
    end

    # if one is garbage collected, we can expect all to eventually be
    # as well
    counter.should be > 1
  end
end
