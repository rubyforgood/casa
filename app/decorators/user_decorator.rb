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

  def formatted_created_at
    object.created_at.strftime(DateFormat::MM_DD_YYYY)
  end

  def formatted_updated_at
    object.updated_at.strftime(DateFormat::MM_DD_YYYY)
  end
end
