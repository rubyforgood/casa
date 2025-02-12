module Api
  extend ActiveSupport::Concern
  included do
    has_one :api_credential, dependent: :destroy
    after_create :initialize_api_credentials
  end

  private

  def initialize_api_credentials
    create_api_credential unless api_credential
  end
end
