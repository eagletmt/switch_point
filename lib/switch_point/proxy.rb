module SwitchPoint
  class Proxy
    attr_reader :initial_name

    AVAILABLE_MODES = [:readonly, :writable]
    DEFAULT_MODE = :readonly

    def initialize(name)
      @initial_name = name
      @current_name = name
      AVAILABLE_MODES.each do |mode|
        model = define_model(name, mode)
        memorize_switch_point(name, mode, model.connection)
      end
      @global_mode = DEFAULT_MODE
    end

    def define_model(name, mode)
      model = Class.new(ActiveRecord::Base)
      model_name = SwitchPoint.config.model_name(name, mode)
      if model_name
        Proxy.const_set(model_name, model)
        model.establish_connection(SwitchPoint.config.database_name(name, mode))
      end
      model
    end

    def memorize_switch_point(name, mode, connection)
      switch_point = { name: name, mode: mode }
      pool = connection.pool
      if pool.equal?(ActiveRecord::Base.connection.pool)
        if mode != :writable
          raise RuntimeError.new("ActiveRecord::Base's switch_points must be writable, but #{name} is #{mode}")
        end
        switch_points = pool.instance_variable_get(:@switch_points) || []
        switch_points << switch_point
        pool.instance_variable_set(:@switch_points, switch_points)
      else
        pool.instance_variable_set(:@switch_point, switch_point)
      end
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
      if thread_local_mode
        self.thread_local_mode = :readonly
      else
        @global_mode = :readonly
      end
    end

    def readonly?
      mode == :readonly
    end

    def writable!
      if thread_local_mode
        self.thread_local_mode = :writable
      else
        @global_mode = :writable
      end
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
      unless AVAILABLE_MODES.include?(new_mode)
        raise ArgumentError.new("Unknown mode: #{new_mode}")
      end
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
      model_name = SwitchPoint.config.model_name(@current_name, mode)
      if model_name
        Proxy.const_get(model_name).connection
      else
        ActiveRecord::Base.connection
      end
    end
  end
end
