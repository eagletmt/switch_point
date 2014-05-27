require 'active_support/lazy_load_hooks'
require 'switch_point/config'
require 'switch_point/version'

module SwitchPoint
  module ClassMethods
    def configure(&block)
      block.call(config)
    end

    def config
      @config ||= Config.new
    end

    def readonly_all!
      config.keys.each do |name|
        readonly!(name)
      end
    end

    def readonly!(name)
      ProxyRepository.find(name).readonly!
    end

    def writable_all!
      config.keys.each do |name|
        writable!(name)
      end
    end

    def writable!(name)
      ProxyRepository.find(name).writable!
    end
  end
  extend ClassMethods
end

ActiveSupport.on_load(:active_record) do
  require 'switch_point/model'
  ActiveRecord::Base.send(:include, SwitchPoint::Model)
end
