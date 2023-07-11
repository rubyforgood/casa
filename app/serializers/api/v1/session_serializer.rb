class Api::V1::SessionSerializer < ActiveModel::Serializer
  type "session"
  attributes :id, :display_name, :email, :token
end
