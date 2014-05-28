require 'switch_point/proxy_repository'

module SwitchPoint
  module ReadonlyConnectionHook
    # See ActiveRecord::ConnectionAdapters::QueryCache
    [:insert, :update, :delete].each do |method_name|
      define_method(method_name) do |*args, &block|
        proxy = ProxyRepository.find(@switch_point_name)
        proxy.with_writable do
          proxy.connection.send(method_name, *args, &block)
        end
      end
    end
  end
end
