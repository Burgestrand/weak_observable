require "ref"
require "weak_observable/version"
require "weak_observable/mixin"
require "weak_observable/hub"

# WeakObservable is like the Observable from standard library,
# with a slightly different API and one important difference:
# it does not keep any strong references to it’s observers.
#
# This is useful in case you want observers, but don’t really
# care if they are garbage collected or not. Mostly useful for
# asynchronous callbacks in C extensions or FFI bindings.
#
# @example
#   observable = WeakObservable.new
#   observer   = Object.new
#
#   observable.add(observer)
#   observable.notify # notifies observable
#
#   observer = nil
#   GC.start # this might garbage collect observer
#   observable.notify # if observer is garbage collected, this does nothing now
class WeakObservable
  def initialize
    @monitor = Ref::SafeMonitor.new
    @observers = Ref::WeakValueMap.new
    @observers.extend(Enumerable)
    @callbacks = Ref::WeakKeyMap.new
  end

  # Add an observer.
  #
  # @note You cannot add the same observer multiple times. The
  #       most recent call overrides any earlier calls; because
  #       of this you can change the method for an observer by
  #       calling add with a new method.
  #
  # @param [#hash] observer
  # @param [String, Symbol] method
  # @return observer, as passed in.
  # @raise ArgumentError if observer does not respond to method.
  def add(observer, method = :update)
    unless observer.respond_to?(method)
      raise ArgumentError, "#{observer} does not respond to #{method}"
    end

    synchronize do
      @callbacks[observer] = method
      @observers[key(observer)] = observer
    end
  end

  # Remove an observer.
  #
  # @param [#hash] observer
  # @return [Object, nil] the observer, or nil if it was not an observer.
  def delete(observer)
    synchronize do
      @callbacks.delete(observer)
      @observers.delete(key(observer))
    end
  end

  # Notify all observers, passing along all arguments and given block.
  #
  # @return [Array] all return values.
  def notify(*args, &block)
    synchronize do
      @observers.map do |_, object|
        callback = @callbacks[object]
        # rare, but could happen if @callbacks is touched by finalizer
        # before the @observers
        next if callback.nil?
        object.send(callback, *args, &block)
      end
    end
  end

  protected

  def key(observer)
    observer.hash
  end

  def synchronize
    @monitor.synchronize { return yield }
  end
end
