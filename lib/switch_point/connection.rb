# frozen_string_literal: true

require 'switch_point/error'
require 'switch_point/proxy_repository'

module SwitchPoint
  module Connection
    # See ActiveRecord::ConnectionAdapters::QueryCache
    DESTRUCTIVE_METHODS = %i[insert update delete].freeze

    DESTRUCTIVE_METHODS.each do |method_name|
      define_method(method_name) do |*args, &block|
        if pool.equal?(ActiveRecord::Base.connection_pool)
          Connection.handle_base_connection(self)
          super(*args, &block)
        else
          parent_method = method(method_name).super_method
          Connection.handle_generated_connection(self, parent_method, method_name, *args, &block)
        end
      end
    end

    def self.handle_base_connection(conn)
      switch_points = conn.pool.spec.config[:switch_points]
      if switch_points
        switch_points.each do |switch_point|
          proxy = ProxyRepository.find(switch_point[:name])
          if switch_point[:mode] != :writable
            raise Error.new("ActiveRecord::Base's switch_points must be writable, but #{switch_point[:name]} is #{switch_point[:mode]}")
          end

          purge_readonly_query_cache(proxy)
        end
      end
    end

    def self.handle_generated_connection(conn, parent_method, method_name, *args, &block)
      switch_point = conn.pool.spec.config[:switch_point]
      if switch_point
        proxy = ProxyRepository.find(switch_point[:name])
        case switch_point[:mode]
        when :readonly
          if SwitchPoint.config.auto_writable?
            proxy_to_writable(proxy, method_name, *args, &block)
          else
            raise ReadonlyError.new("#{switch_point[:name]} is readonly, but destructive method #{method_name} is called")
          end
        when :writable
          purge_readonly_query_cache(proxy)
          parent_method.call(*args, &block)
        else
          raise Error.new("Unknown mode #{switch_point[:mode]} is given with #{name}")
        end
      else
        parent_method.call(*args, &block)
      end
    end

    def self.proxy_to_writable(proxy, method_name, *args, &block)
      proxy.with_writable do
        proxy.connection.send(method_name, *args, &block)
      end
    end

    def self.purge_readonly_query_cache(proxy)
      proxy.with_readonly do
        proxy.connection.clear_query_cache
      end
    end
  end
end
