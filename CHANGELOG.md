## 0.7.0 (2015-10-16)
- `Model.with_readonly` and `Model.with_writable` now raises error when the Model doesn't use switch_point

## 0.6.0 (2015-04-14)
- Add `SwitchPoint::QueryCache` middleware
- `Model.cache` and `Model.uncached` is now hooked by switch_point
    - `Model.cache` enables query cache for both readonly and writable.
    - `Model.uncached` disables query cache for both readonly and writable.
- Add `SwitchPoint.with_readonly_all` and `SwitchPoint.with_writable_all` as shorthand

## 0.5.0 (2014-11-05)
- Rename `SwitchPoint.with_connection` to `SwitchPoint.with_mode`
    - To avoid confusion with `ActiveRecord::ConnectionPool#with_connection`
- Inherit superclass' switch_point configuration

## 0.4.4 (2014-07-14)
- Memorize switch_point config to ConnectionSpecification#config instead of ConnectionPool
    - To support multi-threaded environment since Rails 4.0.

## 0.4.3 (2014-06-24)
- Add Model.transaction_with method (#2, @ryopeko)

## 0.4.2 (2014-06-19)
- Establish connection lazily
    - Just like ActiveRecord::Base, real connection isn't created until `.connection` is called

## 0.4.1 (2014-06-19)
- Support :writable only configuration

## 0.4.0 (2014-06-17)
- auto_writable is disabled by default
    - To restore the previous behavior, set `config.auto_writable = true`.
- Add shorthand methods `SwitchPoint.with_readonly`, `SwitchPoint.with_writable`

## 0.3.1 (2014-06-04)
- Support defaulting to writable ActiveRecord::Base connection
    - When `:writable` key is omitted, ActiveRecord::Base is used for the writable connection.

## 0.3.0 (2014-06-04)
- Improve thread safety
- Raise appropriate error if unknown mode is given to with_connection

## 0.2.3 (2014-06-02)
- Support specifying the same database name within different switch_point
- Add Proxy#readonly? and Proxy#writable? predicate

## 0.2.2 (2014-05-30)
- Fix nil error on with_{readonly,writable} from non-switch_point model

## 0.2.1 (2014-05-29)
- Add Proxy#switch_name to switch proxy configuration
- Fix weird nil error when Config#define_switch_point isn't called yet

## 0.2.0 (2014-05-29)
- Always send destructive operations to writable connection
- Fix bug on pooled connections

## 0.1.0 (2014-05-28)
- Initial release
