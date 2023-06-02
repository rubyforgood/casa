class UserDecorator < Draper::Decorator
  # include Users::TimeZone
  delegate_all

  def status
    object.active ? "Active" : "Inactive"
  end

  def local_time_zone
    browser_time_zone
  end

  def formatted_created_at
    format_key = context[:format] || :full
    if format_key == :edit_profile
      I18n.l(object.created_at&.in_time_zone(local_time_zone), format: format_key, default: nil)
    else
      I18n.l(object.created_at, format: format_key, default: nil)
    end
  end

  def formatted_updated_at
    format_key = context[:format] || :full

    if format_key == :edit_profile
      I18n.l(object.updated_at&.in_time_zone(local_time_zone), format: format_key, default: nil)
    else
      I18n.l(object.updated_at, format: format_key, default: nil)
    end
  end

  def formatted_current_sign_in_at
    format_key = context[:format] || :full

    if format_key == :edit_profile
      I18n.l(object.current_sign_in_at&.in_time_zone(local_time_zone), format: format_key, default: nil)
    else
      I18n.l(object.current_sign_in_at, format: format_key, default: nil)
    end
  end

  def formatted_invitation_accepted_at
    format_key = context[:format] || :full

    if format_key == :edit_profile
      I18n.l(object.invitation_accepted_at&.in_time_zone(local_time_zone), format: format_key, default: nil)
    else
      I18n.l(object.invitation_accepted_at, format: format_key, default: nil)
    end
  end

  def formatted_reset_password_sent_at
    format_key = context[:format] || :full

    if format_key == :edit_profile
      I18n.l(object.reset_password_sent_at&.in_time_zone(local_time_zone), format: format_key, default: nil)
    else
      I18n.l(object.reset_password_sent_at, format: format_key, default: nil)
    end
  end

  def formatted_invitation_sent_at
    format_key = context[:format] || :full

    if format_key == :edit_profile
      I18n.l(object.invitation_sent_at&.in_time_zone(local_time_zone), format: format_key, default: nil)
    else
      I18n.l(object.invitation_sent_at, format: format_key, default: nil)
    end
  end
end
