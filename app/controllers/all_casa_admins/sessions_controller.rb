# frozen_string_literal: true

class AllCasaAdmins::SessionsController < Devise::SessionsController
  include Accessible
  include RecoversFromStaleForm

  layout "casa_auth"
  skip_before_action :check_user, only: :destroy # standard:disable Rails/LexicallyScopedActionFilter

  protected

  def sign_in_params
    params.fetch(resource_name, {}).permit(:email, :password)
  end
end
