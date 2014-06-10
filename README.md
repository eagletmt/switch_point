# SwitchPoint
[![Build Status](https://travis-ci.org/eagletmt/switch_point.svg?branch=master)](https://travis-ci.org/eagletmt/switch_point)

Switching database connection between readonly one and writable one.

## Installation

Add this line to your application's Gemfile:

    gem 'switch_point'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install switch_point

## Usage

See [spec/models](spec/models.rb).

## Internals
There's a proxy which holds two connections: readonly one and writable one.
A proxy has a thread-local state indicating the current mode: readonly or writable.

Each ActiveRecord model refers to a proxy.
`ActiveRecord::Base.connection` is hooked and delegated to the referred proxy.

![switch_point](http://gyazo.wanko.cc/switch_point.svg)

## Contributing

1. Fork it ( https://github.com/eagletmt/switch_point/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
