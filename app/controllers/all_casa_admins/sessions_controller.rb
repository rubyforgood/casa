# frozen_string_literal: true

class AllCasaAdmins::SessionsController < Devise::SessionsController
  include Accessible
  skip_before_action :check_user, only: :destroy
end
