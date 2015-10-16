module SwitchPoint
  class Config
    attr_accessor :auto_writable
    alias_method :auto_writable?, :auto_writable

    def initialize
      self.auto_writable = false
    end

    def define_switch_point(name, config)
      assert_valid_config!(config)
      switch_points[name] = config
    end

    def switch_points
      @switch_points ||= {}
    end

    def database_name(name, mode)
      fetch(name)[mode]
    end

    def model_name(name, mode)
      if fetch(name)[mode]
        "#{name}_#{mode}".camelize
      end
    end

    def fetch(name)
      switch_points.fetch(name)
    end

    def keys
      switch_points.keys
    end

    private

    def assert_valid_config!(config)
      unless config.key?(:readonly) || config.key?(:writable)
        raise ArgumentError.new(':readonly or :writable must be specified')
      end
      if config.key?(:readonly)
        unless config[:readonly].is_a?(Symbol)
          raise TypeError.new(":readonly's value must be Symbol")
        end
      end
      if config.key?(:writable)
        unless config[:writable].is_a?(Symbol)
          raise TypeError.new(":writable's value must be Symbol")
        end
      end
      nil
    end
  end
end
