require 'switch_point/proxy_repository'

module SwitchPoint
  module Model
    def self.included(model)
      model.singleton_class.class_eval do
        include ClassMethods
        alias_method_chain :connection, :switch_point
      end
    end

    module ClassMethods
      def connection_with_switch_point
        if @switch_point_name
          switch_point_proxy.connection
        else
          connection_without_switch_point
        end
      end

      def with_readonly(&block)
        switch_point_proxy.with_readonly(&block)
      end

      def with_writable(&block)
        switch_point_proxy.with_writable(&block)
      end

      def use_switch_point(name)
        assert_existing_switch_point!(name)
        @switch_point_name = name
      end

      def switch_point_proxy
        ProxyRepository.checkout(@switch_point_name)
      end

      private

      def assert_existing_switch_point!(name)
        SwitchPoint.config.fetch(name)
      end
    end
  end
end
