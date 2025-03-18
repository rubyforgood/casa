require "digest"

class ApiCredential < ApplicationRecord
  belongs_to :user

  before_save :generate_api_token
  before_save :generate_refresh_token

  # Securely confirm/deny that Hash in db is same as current users token Hash
  def authenticate_api_token(api_token)
    Digest::SHA256.hexdigest(api_token) == api_token_digest
  end

  def authenticate_refresh_token(refresh_token)
    Digest::SHA256.hexdigest(refresh_token) == refresh_token_digest
  end

  # Securely generate and then return new tokens
  def return_new_api_token!
    new_token = generate_api_token
    update_column(:api_token_digest, api_token_digest)
    {api_token: new_token}
  end

  def return_new_refresh_token!(remember_me)
    new_token = generate_refresh_token
    if remember_me
      update_column(:refresh_token_expires_at, 1.year.from_now)
    else
      update_column(:refresh_token_expires_at, 30.days.from_now)
    end
    update_column(:refresh_token_digest, refresh_token_digest)
    {refresh_token: new_token}
  end

  # Verifying token has or has not expired
  def is_api_token_expired?
    token_expires_at < Time.current
  end

  def is_refresh_token_expired?
    refresh_token_expires_at < Time.current
  end

  def revoke_api_token
    update_columns(api_token_digest: nil)
  end

  def revoke_refresh_token
    update_columns(refresh_token_digest: nil)
  end

  private

  # Generate unique tokens and hashes them for secure db storage
  def generate_api_token
    new_api_token = SecureRandom.hex(18)
    self.api_token_digest = Digest::SHA256.hexdigest(new_api_token)
    new_api_token
  end

  def generate_refresh_token
    new_refresh_token = SecureRandom.hex(18)
    self.refresh_token_digest = Digest::SHA256.hexdigest(new_refresh_token)
    new_refresh_token
  end
end

# == Schema Information
#
# Table name: api_credentials
#
#  id                       :bigint           not null, primary key
#  api_token_digest         :string
#  refresh_token_digest     :string
#  refresh_token_expires_at :datetime
#  token_expires_at         :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  user_id                  :bigint           not null
#
# Indexes
#
#  index_api_credentials_on_api_token_digest      (api_token_digest) UNIQUE WHERE (api_token_digest IS NOT NULL)
#  index_api_credentials_on_refresh_token_digest  (refresh_token_digest) UNIQUE WHERE (refresh_token_digest IS NOT NULL)
#  index_api_credentials_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
