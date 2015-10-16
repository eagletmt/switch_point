require 'benchmark/ips'
require 'switch_point'
require 'active_record'

SwitchPoint.configure do |config|
  config.define_switch_point :proxy,
    readonly: :proxy_readonly,
    writable: :proxy_writable
end

class Plain < ActiveRecord::Base
end

class Proxy1 < ActiveRecord::Base
  use_switch_point :proxy
end

class ProxyBase < ActiveRecord::Base
  self.abstract_class = true
  use_switch_point :proxy
end

class Proxy2 < ProxyBase
end

database_config = { adapter: 'sqlite3', database: ':memory:' }
ActiveRecord::Base.configurations = {
  'default' => database_config.dup,
  'proxy_readonly' => database_config.dup,
  'proxy_writable' => database_config.dup,
}
ActiveRecord::Base.establish_connection(:default)

Plain.connection.execute('CREATE TABLE plains (id integer primary key autoincrement)')
[:readonly, :writable].each do |mode|
  ProxyBase.public_send("with_#{mode}") do
    %w[proxy1s proxy2s].each do |table|
      ProxyBase.connection.execute("CREATE TABLE #{table} (id integer primary key autoincrement)")
    end
  end
end

Benchmark.ips do |x|
  x.report('plain') do
    Plain.create
    Plain.first
  end

  x.report('proxy1') do
    Proxy1.with_writable { Proxy1.create }
    Proxy1.first
  end

  x.report('proxy2') do
    Proxy2.with_writable { Proxy2.create }
    Proxy2.first
  end

  x.compare!
end
