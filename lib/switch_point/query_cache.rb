module SwitchPoint
  class QueryCache
    def initialize(app, names = nil)
      @app = app
      @names = names
    end

    def call(env)
      names.reverse.inject(lambda { @app.call(env) }) do |func, name|
        proxy = ProxyRepository.checkout(name)
        readonly = proxy.with_readonly { proxy.connection }
        writable = proxy.with_writable { proxy.connection }
        lambda { readonly.cache { writable.cache(&func) } }
      end.call
    end

    private

    def names
      @names ||= SwitchPoint.config.keys
    end
  end
end
