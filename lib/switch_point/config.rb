module SwitchPoint
  class Config
    def switch_point(name, config)
      assert_valid_config!(config)
      @switch_points ||= {}
      @switch_points[name] = config
    end

    def database_name(name, mode)
      @switch_points[name][mode]
    end

    def model_name(name, mode)
      "#{mode}_#{database_name(name, mode)}".camelize
    end

    def keys
      @switch_points.keys
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
