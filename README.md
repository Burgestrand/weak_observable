# WeakObservable

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
