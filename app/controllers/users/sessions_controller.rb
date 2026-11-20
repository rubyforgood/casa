# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Accessible
  include RecoversFromStaleForm
  layout "casa_auth"
  skip_before_action :check_user, only: :destroy

  protected

  # Neither model includes Devise's :rememberable, so drop :remember_me (and anything else)
  # that the default sanitizer would pass to Model.new on a failed-sign-in re-render.
  # Note: this bypasses devise_parameter_sanitizer for :sign_in.
  def sign_in_params
    params.fetch(resource_name, {}).permit(:email, :password)
  end
end
