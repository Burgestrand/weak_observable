describe WeakObservable::Hub do
  let(:observable) { WeakObservable::Hub.new }
  let(:observer) { stub(:update => 1) }
  let(:key) { 1337 }
  let(:other_key) { 0xDEADBEEF }

  describe "#add and #notify" do
    it "adds an observer for given key" do
      observer.should_receive(:update)

      observable.add(key, observer)
      observable.notify(key)
    end

    it "allows us to specify callback method" do
      observer.should_receive(:trigger)

      observable.add(key, observer, :trigger)
      observable.notify(key)
    end

    it "allows the same observer for multiple keys" do
      observer.should_receive(:update).twice

      observable.add(key, observer)
      observable.add(other_key, observer)

      observable.notify(key)
      observable.notify(other_key)
    end

    it "allows different methods for different keys" do
      observer.should_receive(:update).once
      observer.should_receive(:trigger).once

      observable.add(key, observer)
      observable.add(other_key, observer, :trigger)

      observable.notify(key)
      observable.notify(other_key)
    end

    it "does not allow duplicates for the same key" do
      observer.should_receive(:update).once

      observable.add(key, observer)
      observable.notify(key)
    end

    it "raises an error if observer does not respond to method" do
      expect { observable.add(key, stub) }.to raise_error(ArgumentError)
    end
  end

  describe "#notify" do
    it "notifies observers only with the same key" do
      observer.should_not_receive(:update)

      observable.add(key, observer)
      observable.notify(other_key)
    end

    it "passes along any args and given block" do
      observer.should_receive(:update).with(1, 2).and_return do |x, y, &block|
        block.call(x, y)
      end

      observable.add(key, observer)
      observable.notify(key, 1, 2) { |x, y| x + y }.should eq [3]
    end

    it "returns all return values" do
      observer1 = stub(:update => 1)
      observer2 = stub(:update => 2)

      observable.add(key, observer1)
      observable.add(key, observer2)

      observable.notify(key).should eq [1, 2]
    end
  end

  describe "#delete" do
    it "deletes the observer with the given key" do
      observer.should_not_receive(:update)

      observable.add(key, observer)
      observable.delete(key, observer)
      observable.notify(key).should eq []
    end

    it "does not crash trying to remove a non-existing observer" do
      observable.add(key, observer)
      expect { observable.delete(key, stub) }.to_not raise_error
    end

    it "does not crash trying to remove an observer with a non-existing key" do
      expect { observable.delete(key, observer) }.to_not raise_error
    end

    it "keeps the observer for other keys" do
      observer1 = stub(:update => 1)
      observer2 = stub(:update => 2)

      observer2.should_not_receive(:update)

      observable.add(key, observer1)
      observable.add(other_key, observer2)
      observable.delete(other_key, observer2)

      observable.notify(key).should eq [1]
      observable.notify(other_key).should eq []
    end

    it "does not remove any other observer for a given key" do
      observer1 = stub(:update => 1)
      observer2 = stub(:update => 2)

      observer2.should_not_receive(:update)

      observable.add(key, observer1)
      observable.add(key, observer2)
      observable.delete(key, observer2)

      observable.notify(key).should eq [1]
    end
  end

  specify "observers can be garbage collected" do
    Ref::Mock.use do
      observer1 = double
      observer2 = double

      observer1.should_not_receive(:update)
      observer2.should_receive(:update)

      observable.add(key, observer1)
      observable.add(key, observer2)

      Ref::Mock.gc(observer1)

      observable.notify(key)
    end
  end

  specify "entire keys can be garbage collected" do
    mapping = lambda { |key| observable.instance_eval { @mapping }[key] }

    Ref::Mock.use do
      observable.add(key, observer)
      expect { Ref::Mock.gc }.to change { mapping[key] }.to(nil)
    end
  end
end
