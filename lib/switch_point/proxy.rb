require 'switch_point/readonly_connection_pool_hook'
require 'switch_point/writable_connection_pool_hook'

module SwitchPoint
  class Proxy
    def initialize(name)
      @models = {}
      [:readonly, :writable].each do |mode|
        model = define_model(SwitchPoint.config.model_name(name, mode))
        @models[mode] = model
        model.establish_connection(SwitchPoint.config.database_name(name, mode))
        memorize_switch_point_name(name, model.connection)
      end
      @models[:readonly].connection.extend(ReadonlyConnectionHook)
      @models[:readonly].connection.pool.singleton_class.send(:include, ReadonlyConnectionPoolHook)
      @models[:writable].connection.extend(WritableConnectionHook)
      @models[:writable].connection.pool.singleton_class.send(:include, WritableConnectionPoolHook)
      @mode = :readonly
    end

    def define_model(model_name)
      model = Class.new(ActiveRecord::Base)
      Proxy.const_set(model_name, model)
      model
    end

    def memorize_switch_point_name(name, connection)
      connection.pool.instance_variable_set(:@switch_point_name, name)
    end

    def readonly!
      @mode = :readonly
    end

    def writable!
      @mode = :writable
    end

    def with_readonly(&block)
      with_connection(:readonly, &block)
    end

    def with_writable(&block)
      with_connection(:writable, &block)
    end

    def with_connection(mode, &block)
      saved_mode = @mode
      @mode = mode
      block.call
    ensure
      @mode = saved_mode
    end

    def connection
      @models[@mode].connection
    end
  end
end
