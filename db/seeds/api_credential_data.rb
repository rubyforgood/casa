ApiCredential.destroy_all
users = User.all

users.each do |user|
  ApiCredential.create!(user: user, api_token_digest: Digest::SHA256.hexdigest(SecureRandom.hex(18)), refresh_token_digest: Digest::SHA256.hexdigest(SecureRandom.hex(18)))
end
