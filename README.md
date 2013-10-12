# WeakObservable [![Build Status](https://travis-ci.org/Burgestrand/weak_observable.png?branch=master)](https://travis-ci.org/Burgestrand/weak_observable)

WeakObservable is very similar to Observable from ruby’ standard library, but
with the very important difference in that it allows its subscribers to be
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

## Supported platforms

- CRuby 1.9.2, 1.9.3, 2.0.0
- JRuby 1.9-mode
- Rubinius 1.9-mode

I will not be supporting Ruby 1.8.

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

## LICENSE

Copyright (c) 2012 Kim Burgestrand

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
