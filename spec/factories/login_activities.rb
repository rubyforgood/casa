FactoryBot.define do
  factory :login_activity do
    user
    scope { "user" }
    strategy { "database_authenticatable" }
    identity { user.email }
    success { true }
    context { "session" } # rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument

    ip { "127.0.0.1" }
    user_agent { "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
  end
end
