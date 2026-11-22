require "flipper/adapters/active_support_cache_store"

# Flipper's Rails engine inserts Flipper::Middleware::Memoizer into the
# middleware stack when config.flipper.memoize is true (the default). Pin it on
# explicitly so per-request memoization cannot be disabled accidentally via
# FLIPPER_MEMOIZE=false: each flag is then loaded at most once per request. The
# middleware is appended to the end of the stack, so it wraps the router and
# also covers the Active Storage routes (/rails/active_storage/...).
Rails.application.config.flipper.memoize = true

ActiveSupport.on_load(:active_record) do
  require "flipper/adapters/active_record"

  Flipper.configure do |config|
    config.adapter { Flipper::Adapters::ActiveRecord.new }
    # Short-lived cache in front of the adapter so flag checks do not hit the
    # database on every call. Flag flips can take up to a minute to become
    # visible; see doc/feature_flags.md.
    # NOTE: in flipper 1.4.x the `expires_in:` kwarg is deprecated; pass the
    # TTL as the third positional argument instead.
    config.use Flipper::Adapters::ActiveSupportCacheStore, Rails.cache, 1.minute
  end
end
