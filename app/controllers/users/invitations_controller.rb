# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  # GET /users/invitation/accept?invitation_token=abcdef123456
  def edit
    set_minimum_password_length
    # Ensure the invitation_token is set on the resource from the URL parameter
    resource.invitation_token = params[:invitation_token]

    # Removed logging of invitation tokens for security reasons


    render :edit
  end

  # PUT /users/invitation
  def update
    # Removed logging of invitation tokens for security reasons
    super
  end

  protected

  # Permit the invitation_token parameter
  def update_resource_params
    params.require(resource_name).permit(:invitation_token, :password, :password_confirmation)
  end
end
