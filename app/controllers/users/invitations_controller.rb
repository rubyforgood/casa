class Users::InvitationsController < Devise::InvitationsController
  # On the class, not per action: this app has no `application` layout, so Devise's inherited actions
  # rendered with NO layout at all -- #new came out as a bare fragment with no <title>, no lang, no
  # <main> and no styles (found by the axe sweep). This covers #new and the re-renders of
  # create/update as well as the #edit override below.
  layout "casa_auth"

  # Override the edit action to ensure the invitation_token is properly set in the form
  def edit
    self.resource = resource_class.new
    set_minimum_password_length if respond_to?(:set_minimum_password_length, true)
    resource.invitation_token = params[:invitation_token]
    render :edit
  end
end
