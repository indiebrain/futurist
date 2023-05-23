# Futurist

[![Code Climate](https://codeclimate.com/github/indiebrain/futurist/badges/gpa.svg)](https://codeclimate.com/github/indiebrain/futurist)
[![Test Coverage](https://codeclimate.com/github/indiebrain/futurist/badges/coverage.svg)](https://codeclimate.com/github/indiebrain/futurist/coverage)
## Background

### Goals of Futurist

Provide a mechanism to transparently execute code in parallel.

### On Futures, Promises, and Resolution

A future is a proxy for a result that is initially unknown, usually
because the computation of its value is not yet complete.

The terms Future and Promise are colloquially used as interchangably,
however their formal definitions describe important, distinct
concepts. Formally, a Future is something which holds a value whereas
a Promise is the funciton, or means by which the future's value is
set; note that a promise may be, and is often, executed
asyncrhonously.

"A future is a read-only placeholder view of a
variable. A promise is a writable, single assignment container which
sets the value of the future."
[<sup>1</sup>](https://en.wikipedia.org/wiki/Futures_and_promises)

When a promise computes and sets the value of its future, it is said
to resolve the value of the future.

### Features of Futurist

* Eager promise resolution. Promise resolution begins during Future
  initialization. Futurist resolves its promises in a forked
  process. This allows promises to be resolved in parallel.
* Blocking synchronization semantics. If the value of a future is
  requested before its promise is resolved, the call to value blocks
  until the promise is resolved. This removes the need for
  special-case error handling and allows the client code to be
  ignorant of synchronization code and interact with the future in an
  imperative manner.

### When to use Futurist

* A set of tasks has inherent latency for each task. For example,
  making a set of HTTP requests.
* Task execution benefits from memory isolation provided by process
  forking.

### When NOT to use Futurist

* If the runtime operating system does not support process
  forking. Specifically, "...fork(2) is not available on some
  platforms like Windows and NetBSD
  4." [<sup>2</sup>](http://ruby-doc.org/core-2.3.0/Process.html#method-c-fork)
* If the promise needs to manipulate the process hierarchy. For
  example, if the promise makes use of `Kernel#exec`; `Kernel#exec`
  forks a child process and replaces the current process with the
  newly forked process. This is problematic in the promise as it
  replaces the value resolving process.
* The set of active futures at any given time is greater than the
  maximum number of file descriptors a user is allowed to open on the
  file system. This can be mitigated by processing the set of tasks
  in batches.
* The overhead of process forking outweighs the cost of the latency
  for the set of tasks to be performed.

## Installation

### Directly via RubyGems

```shell
$ gem install futurist
```

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

```shell
$ bundle
```

## Usage

### Create a future

The call to `Futurist::Future#value` will block until the result of
executing the block is available. If an exception occurs during the
block's execution, the call to future.value will reraise the
exception.

```ruby
future = Futurist::Future.new { 3 + 2 }
future.value # blocks until value is available
=> 5
```

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rake rspec` to run the tests. You can also
run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/indiebrain/futurist.

## References

* <sup>1</sup> [https://en.wikipedia.org/wiki/Futures_and_promises](https://en.wikipedia.org/wiki/Futures_and_promises)
* <sup>2</sup> [http://ruby-doc.org/core-2.3.0/Process.html#method-c-fork](http://ruby-doc.org/core-2.3.0/Process.html#method-c-fork)
