require 'switch_point/writable_connection_hook'

module SwitchPoint
  module WritableConnectionPoolHook
    def self.included(base)
      base.alias_method_chain :new_connection, :switch_point
    end

    def new_connection_with_switch_point
      new_connection_without_switch_point.tap do |conn|
        conn.extend(WritableConnectionHook)
      end
    end
  end
end

