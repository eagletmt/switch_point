require 'singleton'
require 'switch_point/proxy'

module SwitchPoint
  class ProxyRepository
    include Singleton

    def self.find(name)
      instance.find(name)
    end

    def find(name)
      proxies[name] ||= Proxy.new(name)
    end

    def proxies
      @proxies ||= {}
    end
  end
end
