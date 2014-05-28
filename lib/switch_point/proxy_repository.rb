require 'singleton'
require 'switch_point/proxy'

module SwitchPoint
  class ProxyRepository
    include Singleton

    def self.checkout(name)
      instance.checkout(name)
    end

    def self.find(name)
      instance.find(name)
    end

    def checkout(name)
      proxies[name] ||= Proxy.new(name)
    end

    def find(name)
      proxies.fetch(name)
    end

    def proxies
      @proxies ||= {}
    end
  end
end
