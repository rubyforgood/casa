# frozen_string_literal: true

# All-CASA-admin password reset on the casa_auth shell (was the Bootstrap layouts/devise).
class AllCasaAdmins::PasswordsController < Devise::PasswordsController
  layout "casa_auth"
end
