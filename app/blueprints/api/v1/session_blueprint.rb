class Api::V1::SessionBlueprint < Blueprinter::Base
  identifier :id

  fields :id, :display_name, :email

  field :api_token do |user|
    user.api_credential&.api_token
  end

  field :token_expires_at do |user|
    user.api_credential&.token_expires_at
  end

  field :refresh_token do |user|
    user.api_credential&.token_expires_at
  end

  field :refresh_token_expires_at do |user|
    user.api_credential&.token_expires_at
  end
end
