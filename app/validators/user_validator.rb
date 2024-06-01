class UserValidator < ActiveModel::Validator
  include PhoneNumberHelper

  def validate(record)
    valid_phone_number_contents(record.phone_number, record)
    validate_presence(:display_name, record)
    at_least_one_communication_preference_selected(record)
    valid_phone_number_if_receive_sms_notifications(record)
    valid_date_of_birth(record.date_of_birth, record)
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

  def valid_phone_number_if_receive_sms_notifications(record)
    if record.receive_sms_notifications && record.phone_number.blank?
      record.errors.add(:base, " Must add a valid phone number to receive SMS notifications.")
    end
  end

  def valid_date_of_birth(date_of_birth, record)
    return unless date_of_birth.present?

    record.errors.add(:base, " Date of birth must be in the past.") unless date_of_birth.past?
    record.errors.add(:base, " Date of birth must be on or after 1/1/1920.") unless date_of_birth >= "1920-01-01".to_date
  end
end
