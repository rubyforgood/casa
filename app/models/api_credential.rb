class ApiCredential < ApplicationRecord
  belongs_to :user

  before_save :hash_tokens

  private

  def hash_tokens
    self.api_token_digest = Digest::SHA256.hexdigest(api_token) if api_token_changed?
    self.refresh_token_digest = Digest::SHA256.hexdigest(refresh_token) if refresh_token_changed?
  end
end
