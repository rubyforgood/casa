class UserValidator < ActiveModel::Validator
  VALID_PHONE_NUMBER_LENGTH = 12
  VALID_COUNTRY_CODE = "+1"
  PHONE_NUMBER_ERROR = "Phone number is not in correct format: 1XXXXXXXXXX"

  def validate(record)
    if !valid_phone_number_contents(record.phone_number)
      record.errors.add(:phone_number, PHONE_NUMBER_ERROR)
    end
  end

  private

  def valid_phone_number_contents(number)
    if number.empty?
        return true
    end

    if number.length != VALID_PHONE_NUMBER_LENGTH
        return false
    end

    country_code = number[0..1]
    phone_number = number[2..number.length]

    if country_code != VALID_COUNTRY_CODE || !phone_number.scan(/\D/).empty?
        return false
    end

    true
  end
end
