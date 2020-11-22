# frozen_string_literal: true

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
      config.each_key do |name|
        readonly!(name)
      end
    end

    def readonly!(name)
      ProxyRepository.checkout(name).readonly!
    end

    def writable_all!
      config.each_key do |name|
        writable!(name)
      end
    end

    def writable!(name)
      ProxyRepository.checkout(name).writable!
    end

    def with_readonly(*names, &block)
      with_mode(:readonly, *names, &block)
    end

    def with_readonly_all(&block)
      with_readonly(*config.keys, &block)
    end

    def with_writable(*names, &block)
      with_mode(:writable, *names, &block)
    end

    def with_writable_all(&block)
      with_writable(*config.keys, &block)
    end

    def with_mode(mode, *names, &block)
      names.reverse.inject(block) do |func, name|
        lambda do
          ProxyRepository.checkout(name).with_mode(mode, &func)
        end
      end.call
    end
  end
  extend ClassMethods
end

ActiveSupport.on_load(:active_record) do
  require 'switch_point/connection'
  require 'switch_point/model'
  require 'switch_point/query_cache'

  ActiveRecord::Base.include SwitchPoint::Model
  ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
    prepend SwitchPoint::Connection
  end
end
