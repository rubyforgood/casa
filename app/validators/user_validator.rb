class UserValidator < ActiveModel::Validator
  VALID_PHONE_NUMBER_LENGTH = 12
  VALID_COUNTRY_CODE = "+1"

  def validate(record)
    valid_phone_number_contents(record.phone_number, record)
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
end
