# frozen_string_literal: true

# Renders Devise's confirmation (resend) page on the casa_auth shell instead of the retired
# Bootstrap layouts/devise.
class Users::ConfirmationsController < Devise::ConfirmationsController
  layout "casa_auth"
end
