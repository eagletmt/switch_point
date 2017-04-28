# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in switch_point.gemspec
gemspec

platforms :ruby do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'json'
end
