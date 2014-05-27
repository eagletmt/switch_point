require 'switch_point/proxy_repository'

module SwitchPoint
  module Model
    def self.included(model)
      model.singleton_class.class_eval do
        include ClassMethods
        prepend ConnectionHook
      end
    end

    module ConnectionHook
      def connection
        if @switch_point_name
          switch_point_proxy.connection
        else
          super
        end
      end

    end

    module ClassMethods
      def with_readonly(&block)
        switch_point_proxy.with_readonly(&block)
      end

      def with_writable(&block)
        switch_point_proxy.with_writable(&block)
      end

      private

      def use_switch_point(name)
        @switch_point_name = name
      end

      def switch_point_proxy
        @switch_point_proxy ||= ProxyRepository.find(@switch_point_name)
      end
    end
  end
end
