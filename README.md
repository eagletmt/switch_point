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

When the writable connection is requested to execute destructive query, the readonly connection clears its query cache.

![switch_point](http://gyazo.wanko.cc/switch_point.svg)

### Special case: ActiveRecord::Base.connection
Basically, each connection managed by a proxy isn't shared between proxies.
But there's one exception: ActiveRecord::Base.

If `:writable` key is omitted (e.g., Nanika1 model in spec/models), it uses `ActiveRecord::Base.connection` as writable one.
When `ActiveRecord::Base.connection` is requested to execute destructive query, all readonly connections managed by a proxy which uses `ActiveRecord::Base.connection` as a writable connection clear query cache.

## Contributing

1. Fork it ( https://github.com/eagletmt/switch_point/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
