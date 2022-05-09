class CasaOrgValidator < ActiveModel::Validator
  VALID_TWILIO_PHONE_NUMBER_LENGTH = 12
  VALID_TWILIO_COUNTRY_CODE = "+1"

  def validate(record)
    valid_twilio_phone_number(record.twilio_phone_number, record)
  end

  private

  def valid_twilio_phone_number(number, record)
    if number.nil? || number.empty?
      return true
    end

    message = "format is invalid. Please follow the format +1XXXXXXXXXX where X is a digit"

    if number.length != VALID_TWILIO_PHONE_NUMBER_LENGTH
      record.errors.add(:twilio_phone_number, message)
      return false
    end

    country_code = number[0..1]
    phone_number = number[2..number.length]

    if country_code != VALID_TWILIO_COUNTRY_CODE
      record.errors.add(:twilio_phone_number, message)
      return false
    end

    if !phone_number.scan(/\D/).empty?
      record.errors.add(:twilio_phone_number, message)
      return false
    end

    true
  end
end
