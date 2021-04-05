class UserDecorator < Draper::Decorator
  delegate_all

  def status
    object.active ? "Active" : "Inactive"
  end

  def formatted_created_at
    I18n.l(object.created_at, format: :full, default: nil)
  end

  def formatted_updated_at
    I18n.l(object.updated_at, format: :full, default: nil)
  end

  def formatted_last_sign_in_at
    I18n.l(object.last_sign_in_at, format: :full, default: nil)
  end

  def formatted_invitation_accepted_at
    I18n.l(object.invitation_accepted_at, format: :full, default: nil)
  end

  def formatted_reset_password_sent_at
    I18n.l(object.reset_password_sent_at, format: :full, default: nil)
  end

  def formatted_invitation_sent_at
    I18n.l(object.invitation_sent_at, format: :full, default: nil)
  end
end
