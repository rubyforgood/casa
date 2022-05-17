class UserValidator < ActiveModel::Validator
  include PhoneNumberHelper

  def validate(record)
    valid_phone_number_contents(record.phone_number, record)
    validate_presence(:display_name, record)
    at_least_one_communication_preference_selected(record)
  end

  private

  def valid_phone_number_contents(number, record)
    valid, error = valid_phone_number(number)

    if !valid
      record.errors.add(:phone_number, error)
    end
  end

  def validate_presence(attribute, record)
    if record[attribute].blank?
      record.errors.add(attribute, " can't be blank")
      return false
    end

    true
  end

  def at_least_one_communication_preference_selected(record)
    record.errors.add(:base, " At least one communication preference must be selected.") unless record.receive_email_notifications || record.receive_sms_notifications
  end
end
