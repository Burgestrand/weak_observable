# WeakObservable [![Build Status](https://secure.travis-ci.org/Burgestrand/weak_observable.png)](http://travis-ci.org/Burgestrand/weak_observable)

WeakObservable is very similar to Observable from ruby’ standard library, but
with the very important difference in that it allows it’s subscribers to be
garbage collected.

## Usage

First, install the gems with rubygems.

```shell
gem install weak_observable
```

Now include it onto any object, set up your subscribers and play away!

```ruby
require 'weak_observable'

class Observer
  def update(event, *args, &block)
    puts "[#{event}]: #{args.inspect}"
  end
end

class Playlist
  include WeakObservable::Mixin
end

# Create an observer to wait for notifications.
observer = Observer.new

playlist = Playlist.new
playlist.observers.add(observer)

# Notify all observers. Any arguments and given block goes out to them all.
playlist.observers.notify(:ping)
# ^ the above ends up calling observer.update(:ping)

# Unassign the variable, allowing the observer to be garbage collected.
observer = nil

# Some time passes, ruby garbage collection eventually kicks in, and now…
playlist.observers.notify(:ping) # nothing happens, we have no observers.
```

There is also the Hub, which is a mix between a WeakObservable and a Hash.
You add observers by associating them with a key. A key can have multiple
observers. When you notify observers, you supply the key, and observers on
that key will be notified, but not any other observers.

```ruby
require 'weak_observable'

hub = WeakObservable::Hub.new

class Ninja
  def update(event, *args)
    puts "Ninjas: #{event}"
  end
end

class Pirate
  def update(event, *args)
    puts "Pirates: #{event}"
  end
end

ninja_a = Ninja.new
ninja_b = Ninja.new

pirate_a = Pirate.new
pirate_b = Pirate.new

hub.add(Ninja, ninja_a)
hub.add(Ninja, ninja_b)
hub.add(Pirate, pirate_a)
hub.add(Pirate, pirate_b)

hub.notify(Pirate, "Ninjarrrs arrr attacking!")
# ^ notifies all the pirates that ninjas are attacking.

hub.notify(Ninja, "All pirates are down.")
# ^ notifies all ninjas the pirates are all dead.
```

When all objects of a given key has been garbage collected, that key will
also be garbage collected. Because of this property Hubs can be extremely
useful interfacing with asynchronous C libraries and their callbacks.

## Contributing

Please fork the repository and clone it. To get started with development you’ll
need to install the development dependencies and make sure you can run the
tests. You can easily install all development dependencies using bundler.

```shell
$> gem install bundler
$> bundle install # => installs development dependencies
```

Once you have the dependencies installed you should be able to run the tests.

```shell
$> rake
```

They should be green. Now go ahead and add your tests, add your changes, and push
it back up to GitHub. Once you feel you’re done create a pull request. Thank you!
