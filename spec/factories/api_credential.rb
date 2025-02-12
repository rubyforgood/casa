FactoryBot.define do
  factory :api_credential do
    association :user
    api_token_digest { Digest::SHA256.hexdigest(SecureRandom.hex(18)) }
    refresh_token_digest { Digest::SHA256.hexdigest(SecureRandom.hex(18)) }
    token_expires_at { 1.hour.from_now }
    refresh_token_expires_at { 1.day.from_now }
  end
end
