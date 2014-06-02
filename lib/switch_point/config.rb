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
      "#{name}_#{mode}".camelize
    end

    def fetch(name)
      switch_points.fetch(name)
    end

    def keys
      switch_points.keys
    end

    private

    def assert_valid_config!(config)
      [:readonly, :writable].each do |mode|
        unless config.has_key?(mode)
          raise ArgumentError.new("#{mode} key is required")
        end
        unless config[mode].is_a?(Symbol)
          raise TypeError.new("#{mode}'s value must be Symbol")
        end
      end
      nil
    end
  end
end
