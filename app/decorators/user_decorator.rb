class UserDecorator < Draper::Decorator
  delegate_all

  def status
    return "Active" if object.active

    "Inactive"
  end

  def formatted_created_at
    I18n.l(object.created_at, format: :standard, default: nil)
  end

  def formatted_updated_at
    I18n.l(object.updated_at, format: :standard, default: nil)
  end

  def formatted_last_sign_in_at
    I18n.l(object.last_sign_in_at, format: :standard, default: nil)
  end
end
