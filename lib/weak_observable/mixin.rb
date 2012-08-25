class WeakObservable
  module Mixin
    def observers
      @__weak_observable_observers__ ||= WeakObservable.new
    end
  end
end
