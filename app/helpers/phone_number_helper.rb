module PhoneNumberHelper
  VALID_PHONE_NUMBER_LENGTH = 12
  VALID_COUNTRY_CODE = "+1"

  def valid_phone_number(number)
    message = " must be 12 digits including country code (+1)"

    if number.nil? || number.empty?
      return true, nil
    end

    if number.length != VALID_PHONE_NUMBER_LENGTH
      return false, message
    end

    country_code = number[0..1]
    phone_number = number[2..number.length]

    if country_code != VALID_COUNTRY_CODE
      return false, message
    end

    if !phone_number.scan(/\D/).empty?
      return false, message
    end

    true, nil
  end
end
