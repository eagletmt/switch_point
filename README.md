# SwitchPoint
[![Gem Version](https://badge.fury.io/rb/switch_point.svg)](http://badge.fury.io/rb/switch_point)
[![Build Status](https://travis-ci.org/eagletmt/switch_point.svg?branch=master)](https://travis-ci.org/eagletmt/switch_point)
[![Coverage Status](https://img.shields.io/coveralls/eagletmt/switch_point.svg?branch=master)](https://coveralls.io/r/eagletmt/switch_point?branch=master)
[![Code Climate](https://codeclimate.com/github/eagletmt/switch_point/badges/gpa.svg)](https://codeclimate.com/github/eagletmt/switch_point)

Switching database connection between readonly one and writable one.

## Installation

Add this line to your application's Gemfile:

    gem 'switch_point'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install switch_point

## Usage
Suppose you have 4 databases: db-blog-master, db-blog-slave, db-comment-master and db-comment-slave.
Article model and Category model are stored in db-blog-{master,slave} and Comment model is stored in db-comment-{master,slave}.

### Configuration
In database.yml:

```yaml
production_blog_master:
  adapter: mysql2
  username: blog_writable
  host: db-blog-master
production_blog_slave:
  adapter: mysql2
  username: blog_readonly
  host: db-blog-slave
production_comment_master:
    ...
```

In initializer:

```ruby
SwitchPoint.configure do |config|
  config.define_switch_point :blog,
    readonly: :"#{Rails.env}_blog_slave",
    writable: :"#{Rails.env}_blog_master"
  config.define_switch_point :comment,
    readonly: :"#{Rails.env}_comment_slave",
    writable: :"#{Rails.env}_comment_master"
end
```

In models:

```ruby
class Article < ActiveRecord::Base
  use_switch_point :blog
end

class Category < ActiveRecord::Base
  use_switch_point :blog
end

class Comment < ActiveRecord::Base
  use_switch_point :comment
end
```

### Switching connections

```ruby
Article.with_readonly { Article.first } # Read from db-blog-slave
Category.with_readonly { Category.first } # Also read from db-blog-slave
Comment.with_readonly { Comment.first } # Read from db-comment-slave

Article.with_readonly do
  article = Article.first  # Read from db-blog-slave
  article.title = 'new title'
  Article.with_writable do
    article.save!  # Write to db-blog-master
    article.reload  # Read from db-blog-master
    Category.first  # Read from db-blog-master
  end
end
```

Note that Article and Category shares their connections.

### Query cache
`Model.cache` and `Model.uncached` enables/disables query cache for both
readonly connection and writable connection.

switch_point also provide a rack middleware `SwitchPoint::QueryCache` similar
to `ActiveRecord::QueryCache`. It enables query cache for all models using
switch_point.

```ruby
# Replace ActiveRecord::QueryCache with SwitchPoint::QueryCache
config.middleware.swap ActiveRecord::QueryCache, SwitchPoint::QueryCache

# Enable query cache for :nanika1 only.
config.middleware.swap ActiveRecord::QueryCache, SwitchPoint::QueryCache, [:nanika1]
```

## Notes

### auto_writable
`auto_writable` is disabled by default.

When `auto_writable` is enabled, destructive queries is sent to writable connection even in readonly mode.
But it does NOT work well on transactions.

Suppose `after_save` callback is set to User model. When `User.create` is called, it proceeds as follows.

1. BEGIN TRANSACTION is sent to READONLY connection.
2. switch_point switches the connection to WRITABLE.
3. INSERT statement is sent to WRITABLE connection.
4. switch_point reset the connection to READONLY.
5. after_save callback is called.
    - At this point, the connection is READONLY and in a transaction.
6. COMMIT TRANSACTION is sent to READONLY connection.

### connection-related methods of model
Model has several connection-related methods: `connection_handler`, `connection_pool`, `connected?` and so on.
Since only `connection` method is monkey-patched, other connection-related methods doesn't work properly.
If you'd like to use those methods, send it to `Model.switch_point_proxy.model_for_connection`.

## Internals
There's a proxy which holds two connections: readonly one and writable one.
A proxy has a thread-local state indicating the current mode: readonly or writable.

Each ActiveRecord model refers to a proxy.
`ActiveRecord::Base.connection` is hooked and delegated to the referred proxy.

When the writable connection is requested to execute destructive query, the readonly connection clears its query cache.

![switch_point](https://gyazo.wanko.cc/switch_point.svg)

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
