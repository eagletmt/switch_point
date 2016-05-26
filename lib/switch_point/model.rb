require 'switch_point/error'
require 'switch_point/proxy_repository'

module SwitchPoint
  module Model
    def self.included(model)
      super
      model.singleton_class.class_eval do
        include ClassMethods
        prepend MonkeyPatch
      end
    end

    def with_readonly(&block)
      self.class.with_readonly(&block)
    end

    def with_writable(&block)
      self.class.with_writable(&block)
    end

    def transaction_with(*models, &block)
      self.class.transaction_with(*models, &block)
    end

    module ClassMethods
      def with_readonly(&block)
        if switch_point_proxy
          switch_point_proxy.with_readonly(&block)
        else
          raise UnconfiguredError.new("#{name} isn't configured to use switch_point")
        end
      end

      def with_writable(&block)
        if switch_point_proxy
          switch_point_proxy.with_writable(&block)
        else
          raise UnconfiguredError.new("#{name} isn't configured to use switch_point")
        end
      end

      def use_switch_point(name)
        assert_existing_switch_point!(name)
        @switch_point_name = name
      end

      def switch_point_proxy
        if defined?(@switch_point_name)
          ProxyRepository.checkout(@switch_point_name)
        elsif self == ActiveRecord::Base
          nil
        else
          superclass.switch_point_proxy
        end
      end

      def transaction_with(*models, &block)
        unless can_transaction_with?(*models)
          raise Error.new("switch_point's model names must be consistent")
        end

        with_writable do
          transaction(&block)
        end
      end

      private

      def assert_existing_switch_point!(name)
        SwitchPoint.config.fetch(name)
      end

      def can_transaction_with?(*models)
        writable_switch_points = [self, *models].map do |model|
          if model.instance_variable_defined?(:@switch_point_name)
            SwitchPoint.config.model_name(
              model.instance_variable_get(:@switch_point_name),
              :writable
            )
          end
        end

        writable_switch_points.uniq.size == 1
      end
    end

    module MonkeyPatch
      def connection
        if switch_point_proxy
          switch_point_proxy.connection
        else
          super
        end
      end

      def cache(&block)
        if switch_point_proxy
          switch_point_proxy.cache(&block)
        else
          super
        end
      end

      def uncached(&block)
        if switch_point_proxy
          switch_point_proxy.uncached(&block)
        else
          super
        end
      end
    end
  end
end
