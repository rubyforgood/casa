class Api::V1::SessionBlueprint < Blueprinter::Base
  field :user do |user|
    {
      id: user.id,
      display_name: user.display_name,
      email: user.email,
      refresh_token_expires_at: user.api_credential&.refresh_token_expires_at,
      token_expires_at: user.api_credential&.token_expires_at
    }
  end

  field :api_token do |user|
    token = user.api_credential || user.create_api_credential
    token.return_new_api_token![:api_token]
  end

  field :refresh_token do |user|
    token = user.api_credential || user.create_api_credential
    token.return_new_refresh_token![:refresh_token]
  end
end
