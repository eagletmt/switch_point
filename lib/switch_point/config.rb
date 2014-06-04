module SwitchPoint
  class Config
    def define_switch_point(name, config)
      assert_valid_config!(config)
      switch_points[name] = config
    end

    def switch_points
      @switch_points ||= {}
    end

    def database_name(name, mode)
      switch_points[name][mode]
    end

    def model_name(name, mode)
      if switch_points[name][mode]
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
      unless config.has_key?(:readonly)
        raise ArgumentError.new(":readonly key is required")
      end
      unless config[:readonly].is_a?(Symbol)
        raise TypeError.new(":readonly's value must be Symbol")
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
