module SwitchPoint
  class Proxy
    attr_reader :initial_name

    def initialize(name)
      @initial_name = name
      @current_name = name
      [:readonly, :writable].each do |mode|
        model = define_model(SwitchPoint.config.model_name(name, mode))
        model.establish_connection(SwitchPoint.config.database_name(name, mode))
        memorize_switch_point(name, mode, model.connection)
      end
      @global_mode = :readonly
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

    def thread_local_mode
      Thread.current[:"switch_point_#{@current_name}_mode"]
    end

    def thread_local_mode=(mode)
      Thread.current[:"switch_point_#{@current_name}_mode"] = mode
    end
    private :thread_local_mode=

    def mode
      thread_local_mode || @global_mode
    end

    def readonly!
      @global_mode = :readonly
    end

    def readonly?
      mode == :readonly
    end

    def writable!
      @global_mode = :writable
    end

    def writable?
      mode == :writable
    end

    def with_readonly(&block)
      with_connection(:readonly, &block)
    end

    def with_writable(&block)
      with_connection(:writable, &block)
    end

    def with_connection(new_mode, &block)
      saved_mode = self.thread_local_mode
      self.thread_local_mode = new_mode
      block.call
    ensure
      self.thread_local_mode = saved_mode
    end

    def switch_name(new_name, &block)
      if block
        begin
          old_name = @current_name
          @current_name = new_name
          block.call
        ensure
          @current_name = old_name
        end
      else
        @current_name = new_name
      end
    end

    def reset_name!
      @current_name = @initial_name
    end

    def connection
      ProxyRepository.checkout(@current_name) # Ensure the target proxy is created
      Proxy.const_get(SwitchPoint.config.model_name(@current_name, mode)).connection
    end
  end
end
