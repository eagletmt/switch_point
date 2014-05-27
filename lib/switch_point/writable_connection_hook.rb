require 'switch_point/proxy_repository'

module SwitchPoint
  # Propagate clear_query_cache in writable connection to readonly connection
  module WritableConnectionHook
    # See ActiveRecord::ConnectionAdapters::QueryCache
    [:insert, :update, :delete].each do |method_name|
      define_method(method_name) do |*args, &block|
        proxy = ProxyRepository.find(@switch_point_name)
        proxy.with_readonly do
          proxy.connection.clear_query_cache
        end
        super(*args, &block)
      end
    end
  end
end
