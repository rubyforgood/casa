class UserDecorator < Draper::Decorator
  delegate_all

  def status
    object.active ? "Active" : "Inactive"
  end

  def local_time_zone
    h.browser_time_zone
  end

  # helper method to 'DRY' up the other methods : )
  def formatted_timestamp(attribute)
    format_key = context[:format] || :full
    timestamp = object.public_send(attribute)

    if format_key == :edit_profile
      I18n.l(timestamp&.in_time_zone(local_time_zone), format: format_key, default: nil)
    else
      I18n.l(timestamp, format: format_key, default: nil)
    end
  end

  def formatted_created_at
    formatted_timestamp(:created_at)
  end

  def formatted_updated_at
    formatted_timestamp(:updated_at)
  end

  def formatted_current_sign_in_at
    formatted_timestamp(:current_sign_in_at)
  end

  def formatted_invitation_accepted_at
    formatted_timestamp(:invitation_accepted_at)
  end

  def formatted_reset_password_sent_at
    formatted_timestamp(:reset_password_sent_at)
  end

  def formatted_invitation_sent_at
    formatted_timestamp(:invitation_sent_at)
  end

  def formatted_birthday
    return "" unless object.date_of_birth.respond_to?(:strftime)

    object.date_of_birth.to_date.to_fs(:short_ordinal)
  end

  def formatted_date_of_birth
    return "" unless object.date_of_birth.respond_to?(:strftime)

    object.date_of_birth.to_date.to_fs(:slashes)
  end
end
