class CasaOrgValidator < ActiveModel::Validator
  include PhoneNumberHelper

  def validate(record)
    valid_twilio_phone_number(record.twilio_phone_number, record)
  end

  private

  def valid_twilio_phone_number(number, record)
    valid, error = valid_phone_number(number)

    if !valid
      record.errors.add(:number, error)
    end
  end
end
