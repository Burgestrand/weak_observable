require 'ostruct'

describe WeakObservable do
  let(:observable) { WeakObservable.new }
  let(:observer)   { stub(:update => nil) }

  it "has a version" do
    WeakObservable::VERSION.should be_a String
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

    it "does not allow duplicates" do
      observer.should_receive(:update).once

      observable.add(observer)
      observable.add(observer)
      observable.notify
    end

    it "raises an error if observer does not respond to method" do
      expect { observable.add(stub) }.to raise_error(ArgumentError)
    end
  end

  describe "#notify" do
    it "passes along any args given block" do
      observer.should_receive(:update).with(1, 2).and_return do |&block|
        block.call(2)
      end

      observable.add(observer)
      observable.notify(1, 2) { |x| x * 2 }.should eq [4]
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

    it "does not remove any other observer" do
      observer1 = stub(:update => 1)
      observer2 = stub(:update => 2)

      observer2.should_not_receive(:update)

      observable.add(observer1)
      observable.add(observer2)
      observable.delete(observer2)

      observable.notify.should eq [1]
    end

    it "does not crash removing a non-existing observer" do
      expect { observable.delete(observer) }.to_not raise_error
    end
  end

  specify "observers can be garbage collected" do
    Ref::Mock.use do
      observer1 = double
      observer2 = double

      observer1.should_not_receive(:update)
      observer2.should_receive(:update)

      observable.add(observer1)
      observable.add(observer2)

      Ref::Mock.gc(observer1)

      observable.notify
    end
  end
end
