require 'switch_point/proxy_repository'

module SwitchPoint
  module Connection
    # See ActiveRecord::ConnectionAdapters::QueryCache
    DESTRUCTIVE_METHODS = [:insert, :update, :delete]

    DESTRUCTIVE_METHODS.each do |method_name|
      define_method(:"#{method_name}_with_switch_point") do |*args, &block|
        switch_point = self.pool.instance_variable_get(:@switch_point)
        parent_method = :"#{method_name}_without_switch_point"
        if switch_point
          proxy = ProxyRepository.find(switch_point[:name])
          case switch_point[:mode]
          when :readonly
            Connection.proxy_to_writable(proxy, method_name, *args, &block)
          when :writable
            Connection.purge_readonly_query_cache(proxy)
            send(parent_method, *args, &block)
          else
            raise RuntimeError.new("Unknown mode #{switch_point[:mode]} is given with #{name}")
          end
        else
          send(parent_method, *args, &block)
        end
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
