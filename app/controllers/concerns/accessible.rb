module Accessible
  extend ActiveSupport::Concern

  included do
    before_action :check_user
  end

  protected

  def check_user
    if current_all_casa_admin
      flash.clear
      # if you have rails_admin. You can redirect anywhere really
      redirect_to(authenticated_all_casa_admin_root_path) and return # rubocop:disable Style/AndOr
    elsif current_user
      flash.clear
      # The authenticated root path can be defined in your routes.rb in: devise_scope :user do...
      redirect_to(authenticated_user_root_path) and return # rubocop:disable Style/AndOr
    end
  end
end
