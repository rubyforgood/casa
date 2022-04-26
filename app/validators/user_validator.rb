class UserValidator < ActiveModel::Validator
  VALID_PHONE_NUMBER_LENGTH = 12
  VALID_COUNTRY_CODE = "+1"

  def validate(record)
    valid_phone_number_contents(record.phone_number, record)
    validate_presence(:email, record)
    validate_presence(:display_name, record)
    at_least_one_communication_preference_selected(record)
  end

  private

  def valid_phone_number_contents(number, record)
    if number.empty?
      return true
    end

    if number.length != VALID_PHONE_NUMBER_LENGTH
      record.errors.add(:phone_number, " must be 12 digits including country code (+1)")
      return false
    end

    country_code = number[0..1]
    phone_number = number[2..number.length]

    if country_code != VALID_COUNTRY_CODE
      record.errors.add(:phone_number, " must have a valid country code (+1)")
      return false
    end

    if !phone_number.scan(/\D/).empty?
      record.errors.add(:phone_number, " must have correct format")
      return false
    end

    true
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
