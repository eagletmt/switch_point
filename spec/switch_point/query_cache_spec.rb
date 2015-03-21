require 'spec_helper'
require 'rack'

class TestApp
  def call(env)
    state = {}
    [Nanika1, Nanika2].each do |model|
      r = model.with_readonly { model.connection.query_cache_enabled }
      w = model.with_writable { model.connection.query_cache_enabled }
      state[model.name] = { readonly: r, writable: r }
    end
    env[:state] = state
    :result
  end
end

RSpec.describe SwitchPoint::QueryCache do
  let(:app) do
    Rack::Builder.new do
      use SwitchPoint::QueryCache
      run TestApp.new
    end
  end

  describe '#call' do
    it 'enables query cache of all models' do
      env = {}
      expect(app.call(env)).to eq(:result)
      expect(env[:state]).to eq(
        'Nanika1' => { readonly: true, writable: true },
        'Nanika2' => { readonly: true, writable: true },
      )
    end

    context 'when names are specified' do
      let(:app) do
        Rack::Builder.new do
          use SwitchPoint::QueryCache, [:main, :nanika1]
          run TestApp.new
        end
      end

      it 'enables query caches of specified models' do
        env = {}
        expect(app.call(env)).to eq(:result)
        expect(env[:state]).to eq(
          'Nanika1' => { readonly: true, writable: true },
          'Nanika2' => { readonly: false, writable: false },
        )
      end
    end

    context 'when unknown name is specified' do
      let(:app) do
        Rack::Builder.new do
          use SwitchPoint::QueryCache, [:unknown]
          run TestApp.new
        end
      end

      it 'raises error' do
        expect { app.call({}) }.to raise_error(KeyError)
      end
    end
  end
end
