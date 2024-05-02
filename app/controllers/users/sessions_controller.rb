# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Accessible
  skip_before_action :check_user, only: :destroy
  after_action :after_login, only: :create

  def after_login
    LoginActivity.create!(user_id: current_user.id, email: current_user.email, current_sign_in_ip: current_user.current_sign_in_ip, current_sign_in_at: Time.now, user_type: current_user.type)
  end
end
