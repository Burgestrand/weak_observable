require "ref"
require "monitor"

class WeakObservable
  class WeakSet
    include Enumerable

    # Construct a set, optionally with intial members.
    #
    # @example creating an empty set
    #   WeakObservable::WeakSet.new
    #
    # @example creating a non-empty set
    #   WeakObservable::WeakSet.new(%w[hello world])
    #
    # @param [#each] enum
    def initialize(enum = nil)
      @contents = Ref::WeakValueMap.new
      @contents.extend(MonitorMixin)
      enum.each { |o| add(o) } unless enum.nil?
    end

    # Enumerate through all objects in the set.
    #
    # If no block is given, an enumerator is returned instead.
    #
    # @note Order is undefined.
    # @yield [object]
    # @yieldparam [Object] object
    # @return [WeakSet] self
    def each
      return enum_for(__method__) unless block_given?
      synchronize do
        @contents.each { |hash, object| yield object }
        self
      end
    end

    # @return [Boolean] true if the set is empty.
    def empty?
      not any?
    end

    # Check if an object is a member of the set.
    #
    # @param [#hash, #eql?] object
    # @return [Boolean] true if the object is in the set.
    def member?(object)
      synchronize do
        subject = @contents[object.hash]
        object.eql?(subject)
      end
    end

    # Add an object to the set.
    #
    # The object is not added to the set if an object with the
    # same #hash exists in the set, that is also #eql? with the
    # object to be added.
    #
    # @param [#hash, #eql?] object
    # @return [Object, nil] object, or nil if it is already in the set.
    def add(object)
      synchronize do
        subject = @contents[object.hash]
        return if object.eql?(subject)
        @contents[object.hash] = object
      end
    end

    # Removes the given object from the set and returns it.
    #
    # If the object does not exist in the set, return nil.
    #
    # @param [#hash, #eql?] object
    # @return [Object, nil] object, or nil if it was not in the set.
    def delete(object)
      synchronize do
        subject = @contents[object.hash]
        return unless object.eql?(subject)
        @contents.delete(object.hash)
      end
    end

    protected

    def synchronize
      @contents.synchronize { return yield }
    end
  end
end
