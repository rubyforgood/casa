# frozen_string_literal: true

require "digest"

class ApiCredential < ApplicationRecord
  belongs_to :user

  before_save :generate_api_token
  before_save :generate_refresh_token

  %w[api_token refresh_token].each do |method_name|
    # Securely confirm/deny that Hash in db is same as current users token Hash
    define_method :"authenticate_#{method_name}" do |token|
      Digest::SHA256.hexdigest(token) == send(:"#{method_name}_digest")
    end

    # Securely generate and then return new tokens
    define_method :"return_new_#{method_name}!" do
      new_token = send(:"generate_#{method_name}")
      update_column(:"#{method_name}_digest", send(:"#{method_name}_digest"))
      {"#{method_name}": new_token}
    end

    # Verifying token has or has not expired
    define_method :"is_#{method_name}_expired?" do
      name = (method_name == "api_token") ? "token" : method_name
      send(:"#{name}_expires_at").past?
    end
  end

  private

  %w[api_token refresh_token].each do |method_name|
    # Generate unique tokens and hashes them for secure db storage

    define_method :"generate_#{method_name}" do
      new_token = SecureRandom.hex(18)
      self["#{method_name}_digest"] = Digest::SHA256.hexdigest(new_token)
      new_token
    end
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
