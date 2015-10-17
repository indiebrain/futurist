# Futurist

[![Build Status](https://travis-ci.org/indiebrain/futurist.svg?branch=master)](https://travis-ci.org/indiebrain/futurist)
[![Code Climate](https://codeclimate.com/github/indiebrain/futurist/badges/gpa.svg)](https://codeclimate.com/github/indiebrain/futurist)
[![Test Coverage](https://codeclimate.com/github/indiebrain/futurist/badges/coverage.svg)](https://codeclimate.com/github/indiebrain/futurist/coverage)

An implementation of the [future](https://en.wikipedia.org/wiki/Futures_and_promises) construct which uses Process forking to resolve its Promise. Promise evaluation is eager, and value resolution blocks until the Promise is resolved.

**Note**
This implementation will only work on OSes which support process forking.

## Installation


### Directly via RubyGems

    $ gem install futurist

then

```ruby
require 'futurist'
```

### or with Bundler

add this line to your application's Gemfile:

```ruby
gem 'futurist'
```

And then execute:

    $ bundle


## Usage

Futures also allow you to background the computation of any block.

### Create a future

The call to `Futurist::Future#value` will block until the result of executing the block is available. If an exception occurs during the block's execution, the call to future.value will reraise the same exception.

```ruby
future = Futurist::Future.new { 3 + 2 }
future.value # blocks until value is available
=> 5
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/indiebrain/futurist.
