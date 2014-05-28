require 'switch_point/readonly_connection_hook'

module SwitchPoint
  module ReadonlyConnectionPoolHook
    def self.included(base)
      base.alias_method_chain :new_connection, :switch_point
    end

    def new_connection_with_switch_point
      new_connection_without_switch_point.tap do |conn|
        conn.extend(ReadonlyConnectionHook)
      end
    end
  end
end
