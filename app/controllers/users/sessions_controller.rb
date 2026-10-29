# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Accessible
  include RecoversFromStaleForm
  layout "casa_auth"
  skip_before_action :check_user, only: :destroy
end
