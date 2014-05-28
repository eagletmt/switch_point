module SwitchPoint
  class Proxy
    def initialize(name)
      @models = {}
      [:readonly, :writable].each do |mode|
        model = define_model(SwitchPoint.config.model_name(name, mode))
        @models[mode] = model
        model.establish_connection(SwitchPoint.config.database_name(name, mode))
        memorize_switch_point(name, mode, model.connection)
      end
      @mode = :readonly
    end

    def define_model(model_name)
      model = Class.new(ActiveRecord::Base)
      Proxy.const_set(model_name, model)
      model
    end

    def memorize_switch_point(name, mode, connection)
      switch_point = { name: name, mode: mode }
      connection.pool.instance_variable_set(:@switch_point, switch_point)
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
