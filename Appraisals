appraise 'rails-3.2' do
  gem 'activerecord', '~> 3.2'

  platforms :ruby do
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'json'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

appraise 'rails-4.0' do
  gem 'activerecord', '~> 4.0'

  platforms :ruby do
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'json'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

appraise 'rails-4.1' do
  gem 'activerecord', '~> 4.1'

  platforms :ruby do
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'json'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

appraise 'rails-4.2' do
  gem 'activerecord', '~> 4.2'

  platforms :ruby do
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'json'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

appraise 'rails-5.0' do
  gem 'activerecord', '>= 5.0.0.rc1'

  platforms :ruby do
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'json'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

appraise 'rails-edge' do
  gem 'activerecord', git: 'https://github.com/rails/rails'
  gem 'arel', git: 'https://github.com/rails/arel'

  platforms :ruby do
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'json'
    gem 'activerecord-jdbcsqlite3-adapter', git: 'https://github.com/jruby/activerecord-jdbc-adapter', branch: 'master'
  end
end

# vim: set ft=ruby:
