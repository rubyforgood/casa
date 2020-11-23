class UserDecorator < Draper::Decorator
  delegate_all

  def status
    return "Active" if object.active

    "Inactive"
  end

  def name
    return object.email if object.display_name.blank?

    object.display_name
  end
end
