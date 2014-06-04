SwitchPoint.configure do |config|
  config.define_switch_point :main,
    readonly: :main_readonly,
    writable: :main_writable
  config.define_switch_point :user,
    readonly: :user,
    writable: :user
  config.define_switch_point :comment,
    readonly: :comment_readonly,
    writable: :comment_writable
  config.define_switch_point :special,
    readonly: :main_readonly_special,
    writable: :main_writable
  config.define_switch_point :nanika1,
    readonly: :main_readonly
  config.define_switch_point :nanika2,
    readonly: :main_readonly
end

class Book < ActiveRecord::Base
  use_switch_point :main
end

class Publisher < ActiveRecord::Base
  use_switch_point :main
end

class Comment < ActiveRecord::Base
  use_switch_point :comment
end

class User < ActiveRecord::Base
  use_switch_point :user
end

class BigData < ActiveRecord::Base
  use_switch_point :special
end

class Note < ActiveRecord::Base
end

class Nanika1 < ActiveRecord::Base
  use_switch_point :nanika1
end

class Nanika2 < ActiveRecord::Base
  use_switch_point :nanika2
end

base = { adapter: 'sqlite3' }
ActiveRecord::Base.configurations = {
  'main_readonly' => base.merge(database: 'main_readonly.sqlite3'),
  'main_writable' => base.merge(database: 'main_writable.sqlite3'),
  'main_readonly_special' => base.merge(database: 'main_readonly_special.sqlite3'),
  'user' => base.merge(database: 'user.sqlite3'),
  'comment_readonly' => base.merge(database: 'comment_readonly.sqlite3'),
  'comment_writable' => base.merge(database: 'comment_writable.sqlite3'),
  'default' => base.merge(database: 'default.sqlite3')
}
ActiveRecord::Base.establish_connection(:default)
