# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  # GET /users/invitation/accept?invitation_token=abcdef123456
  def edit
    set_minimum_password_length
    # Ensure the invitation_token is set on the resource from the URL parameter
    resource.invitation_token = params[:invitation_token]

    Rails.logger.info "Invitation Edit: Token from params: #{params[:invitation_token]}"
    Rails.logger.info "Invitation Edit: Token set on resource: #{resource.invitation_token}"

    render :edit
  end

  # PUT /users/invitation
  def update
    Rails.logger.info "Invitation Update: Params received: #{update_resource_params.inspect}"
    Rails.logger.info "Invitation Update: invitation_token in params: #{update_resource_params[:invitation_token]}"

    super
  end

  protected

  # Permit the invitation_token parameter
  def update_resource_params
    params.require(resource_name).permit(:invitation_token, :password, :password_confirmation)
  end
end
