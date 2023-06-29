module Accessible
  extend ActiveSupport::Concern

  included do
    before_action :check_user
  end

  protected

  def check_user
    if current_all_casa_admin
      flash.clear
      redirect_to(authenticated_all_casa_admin_root_path) and return
      # override "after_sign_in_path_for" and redirect user to root path if no target URL is stored in session
    elsif request.format.html? && current_user && session[:user_return_to].nil?
      flash.clear
      # The authenticated root path can be defined in your routes.rb in: devise_scope :user do...
      redirect_to(authenticated_user_root_path) and return
    end
  end
end
