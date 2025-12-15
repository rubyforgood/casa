class Users::InvitationsController < Devise::InvitationsController
  # Override the edit action to ensure the invitation_token is properly set in the form
  def edit
    self.resource = resource_class.new
    set_minimum_password_length if respond_to?(:set_minimum_password_length, true)
    resource.invitation_token = params[:invitation_token]
    render :edit
  end
end
