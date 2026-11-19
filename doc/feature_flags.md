# Feature flags (Flipper)

Feature flags are managed with [Flipper](https://www.flippercloud.io/) and its
web UI at `/flipper` (restricted to all-CASA admins via `CanAccessFlipperUI`).
Flags are stored in the `flipper_features` / `flipper_gates` tables through the
Active Record adapter.

## Performance: caching and per-request memoization

Flag lookups used to hit the database on every `Flipper.enabled?` call (see
<https://github.com/rubyforgood/casa/issues/7397>). Two layers now keep that
cheap:

1. **Per-request memoization** — Flipper's Rails engine inserts
   `Flipper::Middleware::Memoizer` into the middleware stack (pinned on via
   `config.flipper.memoize = true` in `config/initializers/flipper.rb`), so
   each flag is loaded from the adapter at most once per request no matter how
   many times the code checks it. The middleware wraps the router, so it also
   covers the Active Storage routes (`/rails/active_storage/...`), not just app
   controllers.
2. **Short-lived cache** — in `config/initializers/flipper.rb` the Active
   Record adapter is wrapped in
   `Flipper::Adapters::ActiveSupportCacheStore` backed by `Rails.cache` with a
   **1 minute TTL**.

### Consequence: flag flips can take up to a minute to show

Because of the 1 minute cache, enabling or disabling a flag (in the `/flipper`
UI, console, or a rake task) may take **up to 60 seconds** to become visible on
every server process. If you need a flip to be visible immediately, restart the
app or clear the cache (`Rails.cache.clear`) after flipping.

In production the cache is the default per-process store (an in-memory store
per web worker) unless you configure `config.cache_store` (e.g.
`:mem_cache_store` or Redis) in `config/environments/production.rb`, in which
case all workers share the same 1 minute cache.

In development and test, `Rails.cache` is a null store, so the cache layer is
inert there; the per-request memoizer still applies.
