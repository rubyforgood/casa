class Api::V1::SessionBlueprint < Blueprinter::Base
  # TODO: where is this used?
  identifier :id

  fields :id, :display_name, :email, :token
end
