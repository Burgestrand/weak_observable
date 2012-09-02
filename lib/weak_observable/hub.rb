require 'set'

class WeakObservable
  # The Hub is like a hash, mapping a key to an observable.
  #
  # Hub holds no strong references. Objects added as observers
  # for a given key can be garbage collected. When all observers
  # for a given key has been garbage collected, the observable
  # for that key is also (eventually) garbage collected.
  #
  # This class is useful for having observers for a given key
  # without necessarily protecting them from being collected by
  # the garbage collector. Say, if you were mapping a pointer
  # address to a bunch of ruby objects for FFI callbacks.
  #
  # @example
  #   $hub = WeakObservable::Hub.new
  #
  #   def some_callback(address, some_arg)
  #     $hub[address].notify(some_arg)
  #   end
  #
  #   object = Object.new
  #   $hub[pointer.address] = object
  #   SomeFFIBinding.register_callback(object.pointer, :some_callback)
  class Hub
    def initialize
      @mapping = Ref::WeakValueMap.new
      @monitor = Ref::SafeMonitor.new
    end

    # Add an object as an observer for updates related to the given key.
    #
    # @param [#hash, #eql?] key
    # @param object
    # @param [Symbol, String] method
    # @return object
    def add(key, object, method = :update)
      synchronize do
        observable = (@mapping[key] ||= WeakObservable.new)
        backrefs_of(object) << observable
        observable.add(object, method)
      end
    end

    # Remove an object as an observer from updates related to the given key.
    #
    # @param [#hash, #eql?] key
    # @param object
    # @return [Object, nil] object, or nil if it was not an observer for that key
    def delete(key, object)
      synchronize do
        if observable = @mapping[key]
          backrefs_of(object).delete(observable)
          observable.delete(object)
        end
      end
    end

    # Notify all observers listening to events on the given key.
    # All arguments are passed, as well as the given block.
    #
    # @param [#hash, #eql?] key
    # @param args
    # @return [Array] all return values
    def notify(key, *args, &block)
      synchronize do
        if observable = @mapping[key]
          observable.notify(*args, &block)
        end
      end
    end

    protected

    def synchronize
      @monitor.synchronize { return yield }
    end

    # The observers retain their observable, but the hub does not.
    # This way we don’t need to garbage collect our mapping, since
    # when all observers are gone, the observables for the address
    # they are registered to is also eligible for garbage collection.
    def backrefs_of(object)
      ivar = :@__observable__hubs__
      back_hash = if object.instance_variable_defined?(ivar)
        object.instance_variable_get(ivar)
      else
        Hash.new
      end
      object.instance_variable_set(ivar, back_hash)

      # An object may also be attached to several addresses within
      # this hub. We want to allow this, but we don’t care about
      # the addresses so we just keep a list of observables.
      back_hash[object_id] ||= Set.new
    end
  end
end
