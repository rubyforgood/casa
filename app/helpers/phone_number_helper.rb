module PhoneNumberHelper
  VALID_PHONE_NUMBER_LENGTHS = [10, 12]
  VALID_COUNTRY_CODE = "+1"

  def valid_phone_number(number)
    message = "must be 10 digits or 12 digits including country code (+1)"

    if number.nil? || number.empty?
      return true, nil
    end

    if !VALID_PHONE_NUMBER_LENGTHS.include?(number.length)
      return false, message
    end

    if number.length == 12
      country_code = number[0..1]
      phone_number = number[2..number.length]

      if country_code != VALID_COUNTRY_CODE
        return false, message
      end
    else
      phone_number = number
    end

    if !phone_number.scan(/\D/).empty?
      return false, message
    end

    [true, nil]
  end
end
