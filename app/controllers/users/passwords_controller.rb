class Users::PasswordsController < Devise::PasswordsController
  include ApplicationHelper
  include PhoneNumberHelper

  def create
    email = params[resource_name][:email]
    phone_number = params[resource_name][:phone_number]
    # try to find user by email
    if !User.find_by(email: email)
      resource.errors.add(:base, "Email not found")
    end
    # validate and add any errors
    validation = valid_phone_number(phone_number)
    if validation[0]
      User.find_by(phone_number: phone_number) ? "" : resource.errors.add(:base, "Phone number not found")
    else
      resource.errors.add(:phone_number, validation[1])
    end
    # re-render and display errors
    respond_with(resource)
    # otherwise, send reset email and sms
  end
end
