class Api::V1::SessionBlueprint < Blueprinter::Base
  identifier :id

  fields :id, :display_name, :email, :token
end
