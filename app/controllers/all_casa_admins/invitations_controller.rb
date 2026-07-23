# frozen_string_literal: true

# All-CASA-admin invitations on the casa_auth shell (was the Bootstrap layouts/devise).
class AllCasaAdmins::InvitationsController < Devise::InvitationsController
  layout "casa_auth"
end
