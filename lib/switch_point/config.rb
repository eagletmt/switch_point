module SwitchPoint
  class Config
    def initialize
      self.auto_writable = false
    end

    def define_switch_point(name, config)
      assert_valid_config!(config)
      switch_points[name] = config
    end

    def auto_writable=(val)
      @auto_writable = val
    end

    def auto_writable?
      @auto_writable
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
      else
        nil
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
      unless config.has_key?(:readonly) || config.has_key?(:writable)
        raise ArgumentError.new(':readonly or :writable must be specified')
      end
      if config.has_key?(:readonly)
        unless config[:readonly].is_a?(Symbol)
          raise TypeError.new(":readonly's value must be Symbol")
        end
      end
      if config.has_key?(:writable)
        unless config[:writable].is_a?(Symbol)
          raise TypeError.new(":writable's value must be Symbol")
        end
      end
      nil
    end
  end
end
