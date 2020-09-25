module Roles
  extend ActiveSupport::Concern

  def role
    model_name.human.titleize
  end
end
