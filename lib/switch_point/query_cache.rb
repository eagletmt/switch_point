module SwitchPoint
  class QueryCache
    def initialize(app, names = nil)
      @app = app
      @names = names
    end

    def call(env)
      names.reverse.inject(lambda { @app.call(env) }) do |func, name|
        lambda { ProxyRepository.checkout(name).cache(&func) }
      end.call
    end

    private

    def names
      @names ||= SwitchPoint.config.keys
    end
  end
end
