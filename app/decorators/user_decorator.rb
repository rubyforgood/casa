class UserDecorator < Draper::Decorator
  delegate_all

  def status
    object.active ? "Active" : "Inactive"
  end

  def formatted_created_at
    format_key = context[:format] || :full
    I18n.l(object.created_at, format: format_key, default: nil)
  end

  def formatted_updated_at
    format_key = context[:format] || :full
    I18n.l(object.updated_at, format: format_key, default: nil)
  end

  def formatted_current_sign_in_at
    format_key = context[:format] || :full
    I18n.l(object.current_sign_in_at, format: format_key, default: nil)
  end

  def formatted_invitation_accepted_at
    format_key = context[:format] || :full
    I18n.l(object.invitation_accepted_at, format: format_key, default: nil)
  end

  def formatted_reset_password_sent_at
    format_key = context[:format] || :full
    I18n.l(object.reset_password_sent_at, format: format_key, default: nil)
  end

  def formatted_invitation_sent_at
    format_key = context[:format] || :full
    I18n.l(object.invitation_sent_at, format: format_key, default: nil)
  end
end
