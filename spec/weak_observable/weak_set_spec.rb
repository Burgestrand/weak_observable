describe WeakObservable::WeakSet do
  let(:set) { WeakObservable::WeakSet.new }

  describe "#initialize" do
    it "can create an empty set" do
      set = WeakObservable::WeakSet.new
      set.should be_empty
    end

    it "can create a set containing items" do
      set = WeakObservable::WeakSet.new(%w[hi ho])
      set.to_a.should eq %w[hi ho]
    end
  end

  describe "#each" do
    it "is an enumerable" do
      set.should respond_to :each
      set.should be_a Enumerable
    end

    it "returns an enumerator when no block given" do
      set.add("hello")
      enum = set.each
      enum.should be_a Enumerator
      enum.to_a.should eq ["hello"]
    end
  end

  describe "#add" do
    it "adds an object to the set" do
      value = "Hello"
      expect { set.add(value) }
        .to change { set.member?(value) }
        .from(false).to(true)
    end
  end

  describe "#delete" do
    let(:set) { WeakObservable::WeakSet.new(%w[hello]) }

    it "deletes an object from the set" do
      expect { set.delete("hello") }
        .to change { set.member?("hello") }
        .from(true).to(false)
    end
  end
end
